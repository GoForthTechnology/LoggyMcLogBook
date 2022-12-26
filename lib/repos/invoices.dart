import 'package:flutter/cupertino.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';
import 'package:lmlb/repos/appointments.dart';

class Invoices extends ChangeNotifier {
  final StreamingCrudInterface<Invoice> _persistence;
  final Appointments _appointmentRepo;

  Invoices(this._persistence, this._appointmentRepo) {
    _persistence.addListener(() => init());
  }

  Future<Invoices> init() async {
    return this;
  }

  Future<List<Invoice>> get(
      {bool? sorted, String? clientId, bool Function(Invoice)? predicate}) {
    var generalPredicate = predicate ?? (i) => true;
    var clientPredicate = (clientId != null) ? (i) => i.clientId == clientId : (i) => true;
    var combinedPredicate = (i) => generalPredicate(i) && clientPredicate(i);
    return _persistence.getAll().first.then((invoices) => invoices.where(combinedPredicate).toList());
  }

  Future<Invoice?> getSingle(String? id) async {
    if (id == null) {
      return null;
    }
    return _persistence.get(id).first;
  }

  Future<List<Invoice>> getPending({bool? sorted, String? clientId}) {
    return get(clientId: clientId, predicate: wherePending);
  }

  static bool wherePending(Invoice invoice) {
    return invoice.dateBilled == null;
  }

  Stream<List<Invoice>> stream(bool Function(Invoice)? predicate) {
    return _persistence.getAll().map((invoices) => invoices.where(predicate ?? (i) => true).toList());
  }

  Future<List<Invoice>> getReceivable({bool? sorted, String? clientId}) {
    return get(clientId: clientId, predicate: (i) => i.dateBilled != null && i.datePaid == null);
  }

  Future<List<Invoice>> getPaid({bool? sorted, String? clientId}) {
    return get(clientId: clientId, predicate: (i) => i.dateBilled != null && i.datePaid != null);
  }

  Future<Invoice> add(Invoice invoice) async {
    var numInvoices = await _persistence.getAll().first.then((invoices) => invoices.length);
    var newInvoiceNum = numInvoices + 1;
    final newInvoice = Invoice(null, newInvoiceNum, invoice.clientId, invoice.currency, invoice.dateCreated, invoice.dateBilled, invoice.datePaid);
    return _persistence.insert(newInvoice).then((id) => newInvoice.setId(id));
  }

  Future<void> remove(Invoice invoice) async {
    final List<Future<void>> updateOps = [];
    var appointments = await _appointmentRepo.getInvoiced(invoice.id!);
    appointments.forEach((a) {
      updateOps.add(_appointmentRepo.removeFromInvoice(a));
    });
    return Future.wait(updateOps)
        .then((_) => _persistence.remove(invoice.id!));
  }

  Future<void> update(Invoice invoice) {
    if (invoice.id == null) {
      return add(invoice);
    }
    return _persistence.update(invoice);
  }
}
