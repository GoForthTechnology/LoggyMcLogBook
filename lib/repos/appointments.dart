import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/repos/internal/indexed_repo.dart';

class Appointments extends IndexedRepo<String, Appointment> {
  final CrudInterface<Appointment> _persistence;

  Appointments(this._persistence)
      : super((a) => a.clientId, (v, k) => v.id = k, (a, b) => a.id == b.id,
            (a, b) => a.time.compareTo(b.time));

  Future<Appointments> init() {
    return initIndex(_persistence.getAll()).then((_) => this);
  }

  Appointment? getLast(String clientId) {
    final appointments = get(sorted: true, clientId: clientId);
    var lastAppointment;
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].time.isBefore(DateTime.now())) {
        lastAppointment = appointments[i];
      }
    }
    return lastAppointment;
  }

  Appointment? getNext(String clientId) {
    final appointments = getUpcoming(sorted: true, clientId: clientId);
    if (appointments.isEmpty) {
      return null;
    }
    return appointments[0];
  }

  List<Appointment> getUpcoming({bool? sorted, String? clientId}) {
    return get(sorted: sorted, clientId: clientId, predicate: (a) => !a.time.isBefore(DateTime.now()));
  }

  List<Appointment> getPending({bool? sorted, String? clientId}) {
    return get(sorted: sorted, clientId: clientId, predicate: (a) => a.invoiceId == null);
  }

  List<Appointment> getInvoiced(String invoiceId) {
    return get(predicate: (a) => a.invoiceId == invoiceId);
  }

  List<Appointment> get({bool? sorted, String? clientId, bool Function(Appointment)? predicate}) {
    return getFromIndex(keyFilter: clientId, sorted: sorted, predicate: predicate);
  }

  Future<void> add(String clientId, DateTime startTime, Duration duration,
      AppointmentType type) {
    var appointments = getFromIndex(keyFilter: clientId);
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
    final appointment = Appointment(null, type, startTime, duration, clientId, null);
    return addToIndex(appointment, _persistence.insert(appointment));
  }

  Future<void> update(Appointment appointment) {
    return updateIndex(appointment, _persistence.update(appointment));
  }

  Future<void> remove(Appointment appointment) {
    return removeFromIndex(appointment, _persistence.remove(appointment));
  }
}
