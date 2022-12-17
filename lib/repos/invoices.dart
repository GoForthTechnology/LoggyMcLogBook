import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/internal/indexed_repo.dart';

class Invoices extends IndexedRepo<String, Invoice> {
  final CrudInterface<Invoice> _persistence;
  final Appointments _appointmentRepo;

  Invoices(this._persistence, this._appointmentRepo)
      : super((a) => a.clientId, (v, k) => v.id = k, (a, b) => a.id == b.id,
            (a, b) => a.dateCreated.compareTo(b.dateCreated)) {
    _persistence.addListener(() => init());
  }

  Future<Invoices> init() {
    return initIndex(_persistence.getAll()).then((_) => this);
  }

  Future<List<Invoice>> get(
      {bool? sorted, String? clientId, bool Function(Invoice)? predicate}) {
    var generalPredicate = predicate ?? (i) => true;
    var clientPredicate = (clientId != null) ? (i) => i.clientId == clientId : (i) => true;
    var combinedPredicate = (i) => generalPredicate(i) && clientPredicate(i);
    return _persistence.getAll().then((invoices) => invoices.where(combinedPredicate).toList());
  }

  Future<Invoice?> getSingle(String? id) async {
    if (id == null) {
      return null;
    }
    return _persistence.get(id);
  }

  Future<List<Invoice>> getPending({bool? sorted, String? clientId}) {
    return get(clientId: clientId, predicate: (i) => i.dateBilled == null);
  }

  Future<List<Invoice>> getReceivable({bool? sorted, String? clientId}) {
    return get(clientId: clientId, predicate: (i) => i.dateBilled != null && i.datePaid == null);
  }

  Future<List<Invoice>> getPaid({bool? sorted, String? clientId}) {
    return get(clientId: clientId, predicate: (i) => i.dateBilled != null && i.datePaid != null);
  }

  Future<Invoice> add(Invoice invoice) async {
    var numInvoices = await _persistence.getAll().then((invoices) => invoices.length);
    var newInvoiceNum = numInvoices + 1;
    final newInvoice = Invoice(null, newInvoiceNum, invoice.clientId, invoice.currency, invoice.dateCreated, invoice.dateBilled, invoice.datePaid);
    return addToIndex(newInvoice, _persistence.insert(newInvoice))
        .then((savedInvoice) {
      final List<Future<void>> updateOps = [];
      /*appointments.forEach((appointment) => updateOps
          .add(_appointmentRepo.update(appointment.bill(savedInvoice))));*/
      return Future.wait(updateOps).then((_) => savedInvoice);
    });
  }

  Future<void> remove(Invoice invoice) async {
    final List<Future<void>> updateOps = [];
    var appointments = await _appointmentRepo.getInvoiced(invoice.id!);
    appointments.forEach((a) {
      updateOps.add(_appointmentRepo.update(a.bill(null)));
    });
    return Future.wait(updateOps)
        .then((_) => removeFromIndex(invoice, _persistence.remove(invoice)));
  }

  Future<void> update(Invoice invoice) {
    if (invoice.id == null) {
      return add(invoice);
    }
    return updateIndex(invoice, _persistence.update(invoice));
  }
}
