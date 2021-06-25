import 'package:flutter/cupertino.dart';
import 'package:lmlb/database/daos/appointment_dao.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/repos/internal/indexed_repo.dart';

class Appointments extends IndexedRepo<int, Appointment> {
  final AppointmentDao _appointmentDao;

  Appointments(this._appointmentDao)
      : super((a) => a.clientId, (v, k) => v.id = k, (a, b) => a.id == b.id,
            (a, b) => a.time.compareTo(b.time));

  Future<Appointments> init() {
    return initIndex(_appointmentDao.getAll()).then((_) => this);
  }

  Appointment? getLast(int clientId) {
    final appointments = get(sorted: true, clientId: clientId);
    var lastAppointment;
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].time.isBefore(DateTime.now())) {
        lastAppointment = appointments[i];
      }
    }
    return lastAppointment;
  }

  Appointment? getNext(int clientId) {
    final appointments =
        get(sorted: true, clientId: clientId, timeFilter: DateTime.now());
    if (appointments.isEmpty) {
      return null;
    }
    return appointments[0];
  }

  List<Appointment> get({bool? sorted, int? clientId, DateTime? timeFilter}) {
    List<Appointment> appointments = getFromIndex(keyFilter: clientId, sorted: sorted);
    if (timeFilter != null) {
      final priorAppointments = [];
      for (int i = 0; i < appointments.length; i++) {
        if (appointments[i].time.isBefore(timeFilter)) {
          priorAppointments.add(appointments[i]);
        }
      }
      priorAppointments.forEach((a) => appointments.remove(a));
    }
    return appointments;
  }

  Future<void> add(int clientId, DateTime startTime, Duration duration,
      AppointmentType type) {
    var appointments = getFromIndex(keyFilter: clientId);
    if (appointments != null) {
      var overlappingAppointment;
      appointments.forEach((appointment) {
        if (appointment.time.isBefore(startTime) &&
            appointment.endTime().isAfter(startTime)) {
          overlappingAppointment = appointment;
        }
      });
      if (overlappingAppointment != null) {
        return Future.error(
            "Found overlapping appointment $overlappingAppointment");
      }
    }
    final appointment = Appointment(null, type, startTime, duration, clientId);
    return addToIndex(appointment, _appointmentDao.insert(appointment));
  }

  Future<void> update(Appointment appointment) {
    return updateIndex(appointment, _appointmentDao.update(appointment));
  }

  Future<void> remove(Appointment appointment) {
    return removeFromIndex(appointment, _appointmentDao.remove(appointment));
  }
}
