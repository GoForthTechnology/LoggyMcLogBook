
import 'package:flutter/cupertino.dart';

class Appointments extends ChangeNotifier {
  Map<int, List<Appointment>> _appointments = {};

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

  String? add(int clientId, DateTime startTime, Duration duration, AppointmentType type) {
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
        return "Found overlapping appointment $overlappingAppointment";
      }
    }
    var appointment = Appointment(type, startTime, duration, clientId);
    if (appointments == null) {
      _appointments[clientId] = [appointment];
    } else {
      appointments.add(appointment);
    }
    notifyListeners();
    return null;
  }

  String? update(Appointment appointment) {
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
    return "Appointment not found";
  }

  String? remove(Appointment appointment) {
    bool? removed = _appointments[appointment.clientId]?.remove(appointment);
    if (removed == null || !removed) {
      return "Appointment not found";
    }
    notifyListeners();
    return null;
  }
}

enum AppointmentType {
  GENERIC,
  INFO,
  INTRO,
  FUP1,
  FUP2,
  FUP3,
  FUP4,
  FUP5,
  FUP6,
  FUP7,
  FUP8,
  FUP9,
  FUP10,
  FUP11,
  FUP12,
  PREG_EVAL
}

extension AppointmentTypeExt on AppointmentType {
  AppointmentType? next() {
    switch(this) {
      case AppointmentType.INTRO:
        return AppointmentType.FUP1;
      case AppointmentType.FUP1:
        return AppointmentType.FUP2;
      case AppointmentType.FUP2:
        return AppointmentType.FUP3;
      case AppointmentType.FUP3:
        return AppointmentType.FUP4;
      case AppointmentType.FUP4:
        return AppointmentType.FUP5;
      case AppointmentType.FUP5:
        return AppointmentType.FUP6;
      case AppointmentType.FUP6:
        return AppointmentType.FUP7;
      case AppointmentType.FUP7:
        return AppointmentType.FUP8;
      case AppointmentType.FUP8:
        return AppointmentType.FUP9;
      case AppointmentType.FUP9:
        return AppointmentType.FUP10;
      case AppointmentType.FUP10:
        return AppointmentType.FUP11;
      case AppointmentType.FUP11:
        return AppointmentType.FUP12;
      default:
        return null;
    }
  }

  String name() {
    return toString().split(".")[1];
  }
}

class Appointment {
  AppointmentType type;
  DateTime time;
  Duration duration;
  int clientId;
  Appointment(
      this.type,
      this.time,
      this.duration,
      this.clientId,
  );

  DateTime endTime() {
    return time.add(duration);
  }
}