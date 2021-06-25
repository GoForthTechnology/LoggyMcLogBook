import 'package:flutter/cupertino.dart';
import 'package:lmlb/database/daos/appointment_dao.dart';
import 'package:lmlb/database/daos/invoice_dao.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/internal/indexed_repo.dart';

class Invoices extends IndexedRepo<int, Invoice> {
  final InvoiceDao _invoiceDao;

  Invoices(this._invoiceDao)
      : super((a) => a.clientId, (v, k) => v.id = k, (a, b) => a.id == b.id, (a, b) => a.dateCreated.compareTo(b.dateCreated));

  Future<Invoices> init() {
    return initIndex(_invoiceDao.getAll()).then((_) => this);
  }

  List<Invoice> get({bool? sorted, int? clientId, bool Function(Invoice)? predicate}) {
    return getFromIndex(keyFilter: clientId, sorted: sorted, predicate: predicate);
  }

  List<Invoice> getPending({bool? sorted, int? clientId}) {
    return get(clientId: clientId, sorted: sorted, predicate: (i) => i.dateBilled == null);
  }

  List<Invoice> getReceivable({bool? sorted, int? clientId}) {
    return get(clientId: clientId, sorted: sorted, predicate: (i) => i.dateBilled != null && i.datePaid == null);
  }

  List<Invoice> getPaid({bool? sorted, int? clientId}) {
    return get(clientId: clientId, sorted: sorted, predicate: (i) => i.dateBilled != null && i.datePaid != null);
  }

  Future<void> add(int clientId, Currency currency) {
    final invoice = Invoice(null, clientId, currency, DateTime.now());
    return addToIndex(invoice, _invoiceDao.insert(invoice));
  }

  Future<void> update(Invoice appointment) {
    return updateIndex(appointment, _invoiceDao.update(appointment));
  }

  Future<void> remove(Invoice appointment) {
    return removeFromIndex(appointment, _invoiceDao.remove(appointment));
  }
}
