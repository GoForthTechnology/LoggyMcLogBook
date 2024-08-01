import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lmlb/persistence/streaming_form_crud.dart';
import 'package:rxdart/rxdart.dart';

class FormKey {
  final String formID;
  final String clientID;

  FormKey({required this.formID, required this.clientID});
}

class FormValue {
  final String value;
  final String comment;

  FormValue({required this.value, this.comment = ""});
}

Future<CollectionReference<FormValue>> clientsUnderUsers(
    FormKey key, Completer<User> userCompleter, FirebaseFirestore db) async {
  var user = await userCompleter.future.timeout(const Duration(seconds: 10));
  return db
      .collection("users")
      .doc(user.uid)
      .collection("clients")
      .doc(key.clientID)
      .collection(key.formID)
      .withConverter<FormValue>(
        fromFirestore: (snapshot, _) {
          var data = snapshot.data()!;
          return FormValue(value: data["value"], comment: data["comment"]);
        },
        toFirestore: (value, _) => {
          "value": value.value,
          "comment": value.comment,
        },
      );
}

Future<CollectionReference<FormValue>> clientsAsProfiles(
    FormKey key, Completer<User> _, FirebaseFirestore db) async {
  return db
      .collection("profiles")
      .doc(key.clientID)
      .collection(key.formID)
      .withConverter<FormValue>(
        fromFirestore: (snapshot, _) {
          var data = snapshot.data()!;
          return FormValue(value: data["value"], comment: data["comment"]);
        },
        toFirestore: (value, _) => {
          "value": value.value,
          "comment": value.comment,
        },
      );
}

class FirestoreFormCrud extends StreamingFormCrudi<FormKey> {
  final FirebaseFirestore db;
  final userCompleter = new Completer<User>();
  final Future<CollectionReference<FormValue>> Function(
      FormKey, Completer<User>, FirebaseFirestore) refFn;

  FirestoreFormCrud(this.refFn) : db = FirebaseFirestore.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !userCompleter.isCompleted) {
        userCompleter.complete(user);
      }
    });
  }

  Future<CollectionReference<FormValue>> _formReference(FormKey key) async {
    var user = await userCompleter.future.timeout(const Duration(seconds: 10));
    return db
        .collection("users")
        .doc(user.uid)
        .collection("clients")
        .doc(key.clientID)
        .collection(key.formID)
        .withConverter<FormValue>(
          fromFirestore: (snapshot, _) {
            var data = snapshot.data()!;
            return FormValue(value: data["value"], comment: data["comment"]);
          },
          toFirestore: (value, _) => {
            "value": value.value,
            "comment": value.comment,
          },
        );
  }

  @override
  Stream<FormValue> getValue(FormKey key, Enum itemID) async* {
    var ref = await refFn(key, userCompleter, db);
    yield* ref
        .doc(itemID.name)
        .snapshots()
        .map((snapshot) => snapshot.data()!)
        .onErrorReturn(FormValue(value: ""));
  }

  @override
  Stream<Map<String, FormValue>> getAllValues(FormKey key) async* {
    var ref = await refFn(key, userCompleter, db);
    yield* ref.snapshots().map((snapshot) {
      Map<String, FormValue> out = {};
      for (var doc in snapshot.docs) {
        out.putIfAbsent(doc.id, () => doc.data());
      }
      return out;
    });
  }

  @override
  Future<void> updateAllValues(
      FormKey key, Map<String, FormValue> values) async {
    var ref = await refFn(key, userCompleter, db);
    var futures = <Future>[];
    values.forEach((key, value) {
      futures.add(ref
          .doc(key)
          .set(value)
          .onError((error, stackTrace) => print("FOO: $error")));
    });
    await Future.wait(futures);
  }

  @override
  Future<void> updateValue(FormKey key, Enum itemID, FormValue value) async {
    var ref = await refFn(key, userCompleter, db);
    await ref.doc(itemID.name).set(value);
  }
}
