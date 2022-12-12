import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/repos/internal/indexed_repo.dart';

class Appointments extends IndexedRepo<String, Appointment> {
  final CrudInterface<Appointment> _persistence;

  Appointments(this._persistence)
      : super((a) => a.clientId, (v, k) => v.id = k, (a, b) => a.id == b.id,
            (a, b) => a.time.compareTo(b.time)) {
    _persistence.addListener(() => init());
  }

  Future<Appointments> init() {
    return initIndex(_persistence.getAll()).then((_) => this);
  }

  Future<Appointment?> getLast(String clientId) async {
    final appointments = await get((a) => a.clientId == clientId);
    print("bar ${appointments.length}");
    var lastAppointment;
    for (int i = 0; i < appointments.length; i++) {
      var appointment = appointments[i];
      if (!appointment.time.isBefore(DateTime.now())) {
        // Appointment is in the future...
        continue;
      }
      if (lastAppointment == null || appointment.time.isAfter(lastAppointment.time)) {
        lastAppointment = appointments[i];
      }
    }
    return lastAppointment;
  }

  Future<Appointment?> getNext(String clientId) async {
    final appointments = await getUpcoming(sorted: true, clientId: clientId);
    if (appointments.isEmpty) {
      return null;
    }
    return appointments[0];
  }

  Future<List<Appointment>> getUpcoming({bool? sorted, String? clientId}) {
    return get((a) => a.clientId == clientId && !a.time.isBefore(DateTime.now()));
  }

  Future<List<Appointment>> getPending({bool? sorted, String? clientId}) async {
    return get((a) => a.clientId == clientId && a.invoiceId == null);
  }

  Future<List<Appointment>> getInvoiced(String invoiceId) async {
    return get((a) => a.invoiceId == invoiceId);
  }

  Future<List<Appointment>> get(bool Function(Appointment) predicate) async {
    var allAppointments = await _persistence.getAll();
    return allAppointments.where(predicate).toList();
  }

  Future<void> add(String clientId, DateTime startTime, Duration duration,
      AppointmentType type, int price) {
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
    final appointment = Appointment(null, type, startTime, duration, clientId, price, null);
    return addToIndex(appointment, _persistence.insert(appointment));
  }

  Future<Appointment?> getSingle(String id) {
    return _persistence.get(id);
  }

  Future<void> update(Appointment appointment) {
    return updateIndex(appointment, _persistence.update(appointment));
  }

  Future<void> remove(Appointment appointment) {
    return removeFromIndex(appointment, _persistence.remove(appointment));
  }
}
