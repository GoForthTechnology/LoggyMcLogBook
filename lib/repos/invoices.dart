import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';
import 'package:lmlb/repos/appointments.dart';

class Invoices extends ChangeNotifier {
  final StreamingCrudInterface<Invoice> _persistence;

  final Appointments appointmentRepo;

  Invoices(this._persistence, this.appointmentRepo);

  Future<void> update(Invoice invoice) async {
    return _persistence.update(invoice).ignore();
  }

  Stream<Invoice?> get(
      {required String clientID, required String invoiceID}) async* {
    // TODO: remove clientID as a required parameter
    yield* _persistence.get(invoiceID);
  }

  Stream<Invoice?> getPending({required String clientID}) async* {
    yield* _persistence
        .getWhere([Criteria("dateBilled", isNull: true)]).map((invoices) {
      if (invoices.isEmpty) {
        return null;
      }
      if (invoices.length > 1) {
        throw Exception("Found multiple pending invoices!");
      }
      return invoices.first;
    });
  }

  Stream<List<Invoice>> getOutstanding({required String clientID}) async* {
    yield* _persistence.getWhere([
      Criteria("dateBilled", isNull: false),
      Criteria("datePaid", isNull: true),
    ]);
  }

  Stream<List<Invoice>> list({String? clientID}) async* {
    yield* _persistence.getAll();
  }

  Future<int> _nextInvoiceNum() async {
    var invoices = await list().first;
    if (invoices.isEmpty) {
      return 1;
    }
    invoices = invoices.where((i) => i.num != null).toList();
    invoices.sort((a, b) => a.num!.compareTo(b.num!));
    return invoices.last.num! + 1;
  }

  Future<Invoice?> _pendingInvoice(String clientID) async {
    return _persistence
        .getWhere([Criteria("fieldateBilled", isNull: true)]).map((invoices) {
      if (invoices.isEmpty) {
        return null;
      }
      if (invoices.length > 1) {
        throw Exception(
            "Only one invoice should be pending for client $clientID");
      }
      return invoices.first;
    }).first;
  }

  Future<String> create(String clientID, Client client,
      {List<Appointment> appointments = const []}) async {
    var pendingInvoice = await _pendingInvoice(clientID);
    if (pendingInvoice != null) {
      throw Exception(
          "Invoice Num ${pendingInvoice.invoiceNumStr()} already pending!");
    }
    if (client.currency == null) {
      throw Exception("Client is missing a currency selection!");
    }
    var nextInvoiceNum = await _nextInvoiceNum();
    var invoiceID = await _persistence.insert(Invoice(
      clientID: clientID,
      currency: client.currency!,
      dateCreated: DateTime.now(),
      num: nextInvoiceNum,
      appointmentEntries: appointments
          .map((a) => AppointmentEntry(
              appointmentID: a.id!,
              appointmentType: a.type,
              appointmentDate: a.time,
              price: client.defaultFollowUpPrice ?? 0))
          .toList(),
    ));
    await Future.wait(appointments
        .map((a) =>
            appointmentRepo.updateAppointment(a.copyWith(invoiceID: invoiceID)))
        .toList());
    return invoiceID;
  }

  Future<void> updateAppointmentPrice(String clientID, String invoiceID,
      String appointmentID, int newPrice) async {
    var invoice = await get(clientID: clientID, invoiceID: invoiceID).first;
    if (invoice == null) {
      throw Exception("could not find invoice!");
    }
    List<AppointmentEntry> updatedAppointmentEntries = [];
    for (var entry in invoice.appointmentEntries) {
      if (entry.appointmentID != appointmentID) {
        updatedAppointmentEntries.add(entry);
        continue;
      }
      updatedAppointmentEntries.add(AppointmentEntry(
        appointmentID: entry.appointmentID,
        appointmentType: entry.appointmentType,
        appointmentDate: entry.appointmentDate,
        price: newPrice,
      ));
    }
    await update(
        invoice.copyWith(appointmentEntries: updatedAppointmentEntries));
  }

  Future<Invoice> removeAppointment(
      Invoice invoice, String appointmentID) async {
    var appointment = await appointmentRepo
        .stream(appointmentID: appointmentID, clientID: invoice.clientID)
        .first;
    if (appointment == null) {
      throw Exception("Appointment $appointmentID not found");
    }
    var updatedEntries = invoice.appointmentEntries
        .where((e) => e.appointmentID != appointmentID)
        .toList();
    var updatedInvoice = invoice.copyWith(appointmentEntries: updatedEntries);
    try {
      await appointmentRepo.updateAppointment(appointment.clearInvoice());
      await update(updatedInvoice);
      return updatedInvoice;
    } catch (e) {
      rethrow;
    }
  }
}
