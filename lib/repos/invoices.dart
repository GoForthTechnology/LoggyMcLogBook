import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/internal/indexed_repo.dart';

class Invoices extends IndexedRepo<String, Invoice> {
  final CrudInterface<Invoice> _persistence;
  final Appointments _appointmentRepo;

  Invoices(this._persistence, this._appointmentRepo)
      : super((a) => a.clientId, (v, k) => v.id = k, (a, b) => a.id == b.id,
            (a, b) => a.dateCreated.compareTo(b.dateCreated));

  Future<Invoices> init() {
    return initIndex(_persistence.getAll()).then((_) => this);
  }

  List<Invoice> get(
      {bool? sorted, String? clientId, bool Function(Invoice)? predicate}) {
    return getFromIndex(
        keyFilter: clientId, sorted: sorted, predicate: predicate);
  }

  List<Invoice> getPending({bool? sorted, String? clientId}) {
    return get(
        clientId: clientId,
        sorted: sorted,
        predicate: (i) => i.dateBilled == null);
  }

  List<Invoice> getReceivable({bool? sorted, String? clientId}) {
    return get(
        clientId: clientId,
        sorted: sorted,
        predicate: (i) => i.dateBilled != null && i.datePaid == null);
  }

  List<Invoice> getPaid({bool? sorted, String? clientId}) {
    return get(
        clientId: clientId,
        sorted: sorted,
        predicate: (i) => i.dateBilled != null && i.datePaid != null);
  }

  Future<Invoice> add(
      String clientId, Currency currency, List<Appointment> appointments) {
    final invoice = Invoice(null, clientId, currency, DateTime.now());
    return addToIndex(invoice, _persistence.insert(invoice))
        .then((savedInvoice) {
      final List<Future<void>> updateOps = [];
      appointments.forEach((appointment) => updateOps
          .add(_appointmentRepo.update(appointment.bill(savedInvoice))));
      return Future.wait(updateOps).then((_) => savedInvoice);
    });
  }

  Future<void> remove(Invoice invoice) {
    final List<Future<void>> updateOps = [];
    _appointmentRepo.getInvoiced(invoice.id!).forEach((appointment) {
      updateOps.add(_appointmentRepo.update(appointment.bill(null)));
    });
    return Future.wait(updateOps)
        .then((_) => removeFromIndex(invoice, _persistence.remove(invoice)));
  }

  Future<void> update(Invoice appointment) {
    return updateIndex(appointment, _persistence.update(appointment));
  }
}
