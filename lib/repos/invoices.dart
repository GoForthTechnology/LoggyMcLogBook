import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/invoice.dart';

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
      query = query.where("clientId", isEqualTo: clientID);
    }
    yield* query
        .withConverter<Invoice>(
            fromFirestore: (snapshots, _) =>
                Invoice.fromJson(snapshots.data() ?? {}).setId(snapshots.id),
            toFirestore: (value, _) => value.toJson())
        .snapshots()
        .map((snapshots) => snapshots.docs.map((e) => e.data()).toList());
  }

  Future<String> create(String clientID, Currency currency) async {
    var ref = await _ref(clientID);
    return ref
        .add(Invoice(
          clientID: clientID,
          currency: currency,
          dateCreated: DateTime.now(),
        ))
        .then((doc) => doc.id);
  }
}
