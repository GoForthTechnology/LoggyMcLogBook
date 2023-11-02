import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class Appointments extends ChangeNotifier {

  final StreamingCrudInterface<Appointment> _persistence;

  Appointments(this._persistence);

  Future<Appointment?> getNext(Appointment appointment) {
    return streamAll((a) => a.clientId == appointment.clientId && a.time.isAfter(appointment.time)).first.then((as) {
      if (as.isEmpty) {
        return null;
      }
      as.sort((a, b) => a.time.compareTo(b.time));
      return as.first;
    });
  }

  Future<Appointment?> getPrevious(Appointment appointment) {
    return streamAll((a) => a.clientId == appointment.clientId && a.time.isBefore(appointment.time)).first.then((as) {
      if (as.isEmpty) {
        return null;
      }
      as.sort((a, b) => a.time.compareTo(b.time));
      return as.last;
    });
  }

  Stream<List<Appointment>> streamAll(bool Function(Appointment) predicate) async* {
    yield* _persistence.getAll().map((as) => as.where(predicate).toList());
  }

  Future<void> add(String clientId, DateTime startTime, Duration duration,
      AppointmentType type) async {
    return _persistence.insert(Appointment(type: type, time: startTime, duration: duration, clientId: clientId)).ignore();
  }

  Stream<Appointment?> stream(String id) {
    return _persistence.get(id);
  }

  Future<void> updateAppointment(Appointment updatedAppointemnt) async {
    // TODO: implement
  }
}
