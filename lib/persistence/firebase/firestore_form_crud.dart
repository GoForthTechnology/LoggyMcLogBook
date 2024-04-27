import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lmlb/persistence/streaming_form_crud.dart';

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

class FirestoreFormCrud<E> extends StreamingFormCrud {
  final FirebaseFirestore db;
  final userCompleter = new Completer<User>();

  FirestoreFormCrud() : db = FirebaseFirestore.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !userCompleter.isCompleted) {
        userCompleter.complete(user);
      }
    });
  }

  Future<CollectionReference<FormValue>> _formReference(FormKey key) async {
    var user = await userCompleter.future.timeout(Duration(seconds: 10));
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
    var ref = await _formReference(key);
    yield* ref.doc(itemID.name).snapshots().map((snapshot) => snapshot.data()!);
  }

  @override
  Stream<Map<String, FormValue>> getAllValues(FormKey key) async* {
    var ref = await _formReference(key);
    yield* ref.snapshots().map((snapshot) {
      Map<String, FormValue> out = {};
      snapshot.docs.forEach((doc) {
        out.putIfAbsent(doc.id, () => doc.data());
      });
      return out;
    });
  }

  @override
  Future<void> updateAllValues(
      FormKey key, Map<String, FormValue> values) async {
    var ref = await _formReference(key);
    var futures = <Future>[];
    values.forEach((key, value) {
      futures.add(ref
          .doc(key)
          .set(value)
          .onError((error, stackTrace) => print("FOO: $error")));
    });
    await futures;
  }

  @override
  Future<void> updateValue(FormKey key, Enum itemID, FormValue value) async {
    var ref = await _formReference(key);
    await ref.doc(itemID.name).set(value);
  }
}
