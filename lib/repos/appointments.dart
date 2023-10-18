import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class Appointments extends ChangeNotifier {
  final StreamingCrudInterface<Appointment> _persistence;

  Appointments(this._persistence);

  Future<Appointments> init() async {
    return this;
  }

  Future<Appointment?> getNext(Appointment appointment) {
    return get((a) => a.clientId == appointment.clientId && a.time.isAfter(appointment.time)).then((as) {
      if (as.isEmpty) {
        return null;
      }
      as.sort((a, b) => a.time.compareTo(b.time));
      return as.first;
    });
  }

  Future<Appointment?> getPrevious(Appointment appointment) {
    return get((a) => a.clientId == appointment.clientId && a.time.isBefore(appointment.time)).then((as) {
      if (as.isEmpty) {
        return null;
      }
      as.sort((a, b) => a.time.compareTo(b.time));
      return as.last;
    });
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
