import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreSubcollectionCrud<T> {
  final FirebaseFirestore _db;
  final _userCompleter = new Completer<User>();

  final String primaryCollectionName;
  final String subcollectionName;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  FireStoreSubcollectionCrud(
      {required this.primaryCollectionName,
      required this.subcollectionName,
      required this.fromJson,
      required this.toJson})
      : _db = FirebaseFirestore.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null && !_userCompleter.isCompleted) {
        _userCompleter.complete(user);
      }
    });
  }

  Future<CollectionReference<T>> _ref(String primaryDocID) async {
    var user = await _userCompleter.future.timeout(Duration(seconds: 10));
    return _db
        .collection("users")
        .doc(user.uid)
        .collection(primaryCollectionName)
        .doc(primaryDocID)
        .collection(subcollectionName)
        .withConverter<T>(
          fromFirestore: (snapshots, _) => fromJson(snapshots),
          toFirestore: (value, _) => toJson(value),
        );
  }

  Stream<T?> streamDoc(
      {required String docID, required String primaryDocID}) async* {
    var query = await _ref(primaryDocID);

    yield* query.doc(docID).snapshots().map((s) => s.data());
  }

  Stream<List<T>> streamCollection({required String primaryDocID}) async* {
    var query = await _ref(primaryDocID);
    yield* query.snapshots().map((s) => s.docs.map((qs) => qs.data()).toList());
  }

  Future<void> addDoc({required T doc, required String primaryDocID}) async {
    var query = await _ref(primaryDocID);
    query.add(doc);
  }

  Future<void> removeDoc(
      {required String primaryDocID, required String docID}) async {
    var query = await _ref(primaryDocID);
    query.doc(docID).delete();
  }

  Future<void> update(
      {required T doc,
      required String primaryDocID,
      required String docID}) async {
    var query = await _ref(primaryDocID);
    query.doc(docID).update(toJson(doc));
  }
}
