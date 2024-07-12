import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class Appointments extends ChangeNotifier {
  final StreamingCrudInterface<Appointment> _persistence;

  Appointments(this._persistence);

  Future<Appointment?> getNext(Appointment appointment) {
    return streamAll((a) =>
        a.clientID == appointment.clientID &&
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
        a.clientID == appointment.clientID &&
        a.time.isBefore(appointment.time)).first.then((as) {
      if (as.isEmpty) {
        return null;
      }
      as.sort((a, b) => a.time.compareTo(b.time));
      as = as.where((a) => a.time.isBefore(DateTime.now())).toList();
      if (as.isEmpty) {
        return null;
      }
      return as.last;
    });
  }

  Stream<List<Appointment>> streamAll(bool Function(Appointment) predicate,
      {String? clientID,
      bool includeUpcoming = true,
      bool includePast = true}) async* {
    List<Criteria> criteria = [];
    if (clientID != null) {
      criteria.add(Criteria("clientID", isEqualTo: clientID));
    }
    if (!includeUpcoming) {
      criteria.add(
          Criteria("time", isGreaterThan: DateTime.now().toIso8601String()));
    }
    yield* _persistence
        .getWhere(criteria)
        .map((as) => as.where(predicate).toList());
  }

  Future<void> add(String clientId, DateTime startTime, Duration duration,
      AppointmentType type) async {
    return _persistence
        .insert(Appointment(
            type: type,
            time: startTime,
            duration: duration,
            clientID: clientId))
        .ignore();
  }

  Stream<Appointment?> stream(
      {required String appointmentID, required String clientID}) async* {
    // TODO: drop clientID as a required param
    yield* _persistence.get(appointmentID);
  }

  Future<void> updateAppointment(Appointment updatedAppointemnt) async {
    return _persistence.update(updatedAppointemnt);
  }
}
