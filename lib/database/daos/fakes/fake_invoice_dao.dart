import 'package:lmlb/database/daos/invoice_dao.dart';
import 'package:lmlb/entities/invoice.dart';

class FakeInvoiceDao extends InvoiceDao {
  @override
  Future<Invoice?> get(int id) {
    return Future.value(null);
  }

  @override
  Future<List<Invoice>> getAll() {
    return Future.value(List.empty());
  }

  @override
  Future<int> insert(Invoice appointment) {
    return Future.value(0);
  }

  @override
  Future<int> remove(Invoice appointment) {
    return Future.value(0);
  }

  @override
  Future<int> update(Invoice appointment) {
    return Future.value(0);
  }

}