import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:rxdart/rxdart.dart';

class Invoices extends ChangeNotifier {
  final _userCompleter = new Completer<User>();
  final FirebaseFirestore _db;

  Invoices() : _db = FirebaseFirestore.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null && !_userCompleter.isCompleted) {
        _userCompleter.complete(user);
        notifyListeners();
      }
    });
  }

  Future<CollectionReference<Invoice>> _ref(String clientID) async {
    var user = await _userCompleter.future.timeout(Duration(seconds: 10));
    return _db
        .collection("users")
        .doc(user.uid)
        .collection("clients")
        .doc(clientID)
        .collection("invoices")
        .withConverter<Invoice>(
          fromFirestore: (snapshots, _) =>
              Invoice.fromJson(snapshots.data() ?? {}),
          toFirestore: (value, _) => value.toJson(),
        );
  }

  Stream<List<Invoice>> list({String? clientID}) async* {
    var query = _db.collectionGroup("invoices");
    if (clientID != null) {
      query = query.where("clientID", isEqualTo: clientID);
    }
    yield* query
        .withConverter<Invoice>(
            fromFirestore: (snapshots, _) =>
                Invoice.fromJson(snapshots.data() ?? {}).setId(snapshots.id),
            toFirestore: (value, _) => value.toJson())
        .snapshots()
        .map((snapshots) =>
            snapshots.docs.map((e) => e.data().setId(e.id)).toList())
        .doOnError((p0, p1) => print("FOOOOOO: $p0, $p1"));
  }

  Future<int> _nextInvoiceNum() async {
    try {
      var query = _db
          .collectionGroup("invoices")
          .orderBy("num", descending: true)
          .limit(1);
      var snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return 1;
      }
      if (snapshot.docs.length != 1) {
        throw Exception("Expected only one doc!");
      }
      var doc = snapshot.docs[0];
      int num = doc.data()["num"];
      return num + 1;
    } catch (e) {
      print(e);
    }
    return -1;
  }

  Future<Invoice?> _pendingInvoice(String clientID) async {
    var ref = await _ref(clientID);
    var snapshot = await ref
        .where("dateBilled", isNull: true)
        .withConverter<Invoice>(
            fromFirestore: (snapshots, _) =>
                Invoice.fromJson(snapshots.data() ?? {}).setId(snapshots.id),
            toFirestore: (value, _) => value.toJson())
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    if (snapshot.docs.length > 1) {
      throw Exception(
          "Only one invoice should be pending for client $clientID");
    }
    return snapshot.docs[0].data();
  }

  Future<String> create(String clientID, Currency currency) async {
    var pendingInvoice = await _pendingInvoice(clientID);
    if (pendingInvoice != null) {
      throw Exception(
          "Invoice Num ${pendingInvoice.invoiceNumStr()} already pending!");
    }
    var nextInvoiceNum = await _nextInvoiceNum();
    var ref = await _ref(clientID);
    return ref
        .add(Invoice(
          clientID: clientID,
          currency: currency,
          dateCreated: DateTime.now(),
          num: nextInvoiceNum,
        ))
        .then((doc) => doc.id);
  }
}
