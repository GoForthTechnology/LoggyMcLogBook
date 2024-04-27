import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:rxdart/rxdart.dart';

class Appointments extends ChangeNotifier {
  final _userCompleter = new Completer<User>();
  final FirebaseFirestore _db;

  Appointments() : _db = FirebaseFirestore.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null && !_userCompleter.isCompleted) {
        _userCompleter.complete(user);
        notifyListeners();
      }
    });
  }

  Future<CollectionReference<Appointment>> _ref(String clientID) async {
    var user = await _userCompleter.future.timeout(Duration(seconds: 10));
    return _db
        .collection("users")
        .doc(user.uid)
        .collection("clients")
        .doc(clientID)
        .collection("appointments")
        .withConverter<Appointment>(
          fromFirestore: (snapshots, _) =>
              Appointment.fromJson(snapshots.data() ?? {}),
          toFirestore: (value, _) => value.toJson(),
        );
  }

  Future<Appointment?> getNext(Appointment appointment) {
    return streamAll((a) =>
        a.clientId == appointment.clientId &&
        a.time.isAfter(appointment.time)).first.then((as) {
      if (as.isEmpty) {
        return null;
      }
      as.sort((a, b) => a.time.compareTo(b.time));
      return as.first;
    });
  }

  Future<Appointment?> getPrevious(Appointment appointment) {
    return streamAll((a) =>
        a.clientId == appointment.clientId &&
        a.time.isBefore(appointment.time)).first.then((as) {
      if (as.isEmpty) {
        return null;
      }
      as.sort((a, b) => a.time.compareTo(b.time));
      return as.last;
    });
  }

  Stream<List<Appointment>> streamAll(bool Function(Appointment) predicate,
      {String? clientID,
      bool includeUpcoming = true,
      bool includePast = true}) async* {
    var query = _db.collectionGroup("appointments");
    if (clientID != null) {
      query = query.where("clientId", isEqualTo: clientID);
    }
    if (!includeUpcoming) {
      query =
          query.where("time", isGreaterThan: DateTime.now().toIso8601String());
    }
    yield* query
        .withConverter<Appointment>(
            fromFirestore: (snapshots, _) =>
                Appointment.fromJson(snapshots.data() ?? {})
                    .setId(snapshots.id),
            toFirestore: (value, _) => value.toJson())
        .snapshots()
        .map((snapshots) => snapshots.docs.map((e) => e.data()).toList())
        .doOnError((p0, p1) => print("FOOOOOO: $p0, $p1"));
  }

  Future<void> add(String clientId, DateTime startTime, Duration duration,
      AppointmentType type) async {
    var ref = await _ref(clientId);
    return ref
        .add(Appointment(
            type: type,
            time: startTime,
            duration: duration,
            clientId: clientId))
        .ignore();
  }

  Stream<Appointment?> stream(
      {required String appointmentID, required String clientID}) async* {
    var query = await _ref(clientID);

    yield* query.doc(appointmentID).snapshots().map((s) => s.data());
  }

  Future<void> updateAppointment(Appointment updatedAppointemnt) async {
    // TODO: implement
  }
}
