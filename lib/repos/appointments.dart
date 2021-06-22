
import 'package:flutter/cupertino.dart';
import 'package:lmlb/database/daos/appointment_dao.dart';
import 'package:lmlb/entities/appointment.dart';

class Appointments extends ChangeNotifier {
  final AppointmentDao _appointmentDao;
  Map<int, List<Appointment>> _appointments = {};

  Appointments(this._appointmentDao);

  Future<Appointments> init() {
    return _appointmentDao.getAll().then((appointments) {
      appointments.forEach((appointment) {
        if (appointment.clientId != null && _appointments.containsKey(appointment.clientId)) {
          _appointments[appointment.clientId]!.add(appointment);
        } else {
          _appointments[appointment.clientId] = [appointment];
        }
      });
      notifyListeners();
      return this;
    });
  }

  List<Appointment> get({bool? sorted, int? clientId, DateTime? timeFilter}) {
    List<Appointment> appointments = [];
    if (clientId != null && _appointments.containsKey(clientId)) {
      _appointments[clientId]?.forEach((a) => appointments.add(a));
    } else {
      appointments = _appointments.values.expand((a) => a).toList();
    }
    if (sorted != null && sorted) {
      appointments.sort((a, b) => a.time.compareTo(b.time));
    }
    return appointments;
  }

  Future<void> add(int clientId, DateTime startTime, Duration duration, AppointmentType type) {
    var appointments = _appointments[clientId];
    if (appointments != null) {
      var overlappingAppointment;
      appointments.forEach((appointment) {
        if (appointment.time.isBefore(startTime) &&
            appointment.endTime().isAfter(startTime)) {
          overlappingAppointment = appointment;
        }
      });
      if (overlappingAppointment != null) {
        return Future.error("Found overlapping appointment $overlappingAppointment");
      }
    }
    return _appointmentDao.insert(Appointment(null, type, startTime, duration, clientId)).then((id) {
      final updatedAppointment = Appointment(id, type, startTime, duration, clientId);
      if (appointments == null) {
        _appointments[clientId] = [updatedAppointment];
      } else {
        appointments.add(updatedAppointment);
      }
      notifyListeners();
    });
  }

  Future<void> update(Appointment appointment) {
    return _appointmentDao.update(appointment).then((numUpdated) {
      if (numUpdated == 0) {
        return Future.error("No appointment updated in DB");
      }
      var appointments = _appointments[appointment.clientId];
      if (appointments != null) {
        for (int i=0; i<appointments.length; i++) {
          if (appointments[i].time == appointment.time) {
            appointments.removeAt(i);
            appointments.add(appointment);
            notifyListeners();
            return null;
          }
        }
      }
      return Future.error("Appointment not found");
    });
  }

  Future<void> remove(Appointment appointment) {
    return _appointmentDao.remove(appointment).then((numRemoved) {
      if (numRemoved == 0) {
        return Future.error("No appointment removed from DB");
      }
      bool? removed = _appointments[appointment.clientId]?.remove(appointment);
      if (removed == null || !removed) {
        return Future.error("Appointment not found");
      }
      notifyListeners();
    });
  }
}

