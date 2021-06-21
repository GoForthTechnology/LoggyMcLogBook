
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

  String? add(int clientId, DateTime startTime, Duration duration) {
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
    var appointment = Appointment(startTime, duration, clientId);
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

class Appointment {
  DateTime time;
  Duration duration;
  int clientId;
  Appointment(
      this.time,
      this.duration,
      this.clientId,
  );

  DateTime endTime() {
    return time.add(duration);
  }
}