import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fc_forms/fc_forms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FollowUpRepo extends ChangeNotifier {
  static const String _formKey = "FOLLOW-UP-FORM";

  final FirebaseFirestore _db;
  final _userCompleter = new Completer<User>();

  FollowUpRepo() : _db = FirebaseFirestore.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !_userCompleter.isCompleted) {
        _userCompleter.complete(user);
      }
    });
  }

  Future<CollectionReference<FormEntry>> _formReference(String clientID) async {
    var user = await _userCompleter.future.timeout(Duration(seconds: 10));
    return _db
        .collection("users")
        .doc(user.uid)
        .collection("clients")
        .doc(clientID)
        .collection(_formKey)
        .withConverter<FormEntry>(
          fromFirestore: (snapshot, _) =>
              FormEntry.fromJson(snapshot.data() ?? {}),
          toFirestore: (value, _) => value.toJson(),
        );
  }

  Stream<Map<FollowUpFormEntryId, FormEntry>> values(String clientID) async* {
    var ref = await _formReference(clientID);
    yield* ref.snapshots().map((snapshots) {
      Map<FollowUpFormEntryId, FormEntry> out = {};
      for (var doc in snapshots.docs) {
        var entry = doc.data();
        var id = FollowUpFormEntryId(
          section: entry.id.section,
          subSection: entry.id.subSection,
          questionIndex: entry.id.questionIndex,
          followUpIndex: entry.id.followUpIndex,
          subSubSection: entry.id.subSubSection?.isEmpty ?? true
              ? null
              : entry.id.subSubSection,
          superSection: entry.id.superSection?.isEmpty ?? true
              ? null
              : entry.id.superSection,
        );
        out[id] = FormEntry(id: id, value: entry.value);
      }
      return out;
    });
  }

  Future<void> updateAll(String clientID, List<FormEntry> entries) async {
    var ref = await _formReference(clientID);
    List<Future> futures = [];
    for (var entry in entries) {
      futures.add(ref.doc(entry.id.toString()).set(entry));
    }
    await futures;
  }
}

class FormEntry {
  final FollowUpFormEntryId id;
  final String value;

  FormEntry({required this.id, required this.value});

  static FormEntry fromJson(Map<String, dynamic> json) {
    var id = FollowUpFormEntryId.fromJson(json);
    var value = json["value"] ?? "";
    return FormEntry(id: id, value: value);
  }

  Map<String, dynamic> toJson() {
    var json = id.toJson();
    json.addAll({
      "value": value,
    });
    return json;
  }
}
