import 'package:flutter/material.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class Appointments extends ChangeNotifier {
  final StreamingCrudInterface<Appointment> _persistence;

  Appointments(this._persistence);

  Future<Appointments> init() async {
    return this;
  }

  Future<Appointment?> getLast(String clientId) async {
    final appointments = await get((a) => a.clientId == clientId);
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
    var allAppointments = await _persistence.getAll().first;
    return allAppointments.where(predicate).toList();
  }

  Stream<List<Appointment>> streamAll(bool Function(Appointment) predicate) async* {
    yield* _persistence.getAll().map((appointments) => appointments
        .where(predicate).toList());
  }

  Future<void> add(String clientId, DateTime startTime, Duration duration,
      AppointmentType type, int price) {
    final appointment = Appointment(null, type, startTime, duration, clientId, price, null);
    return _persistence.insert(appointment);
  }

  Future<void> updateAppointment(Appointment appointment) {
    return _persistence.update(appointment);
  }

  Future<Appointment> addToInvoice(Appointment appointment, Invoice invoice) {
    var updatedAppointment = appointment.bill(invoice);
    return _persistence.update(appointment.bill(invoice)).then((_) => updatedAppointment);
  }

  Future<Appointment> removeFromInvoice(Appointment appointment) {
    var updatedAppointment = appointment.bill(null);
    return _persistence.update(updatedAppointment).then((_) => updatedAppointment);
  }

  Future<Appointment?> getSingle(String id) {
    return _persistence.get(id).first;
  }

  Stream<Appointment?> stream(String id) {
    return _persistence.get(id);
  }

  Future<void> remove(String appointmentId) {
    return _persistence.remove(appointmentId);
  }
}
