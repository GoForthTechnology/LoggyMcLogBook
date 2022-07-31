
import 'package:floor/floor.dart' as floor;
import 'package:lmlb/entities/invoice.dart';

@floor.dao
abstract class InvoiceDao {

  @floor.Query('SELECT * FROM Invoice')
  Future<List<Invoice>> getAll();

  @floor.Query('SELECT * FROM Invoice WHERE id = :id')
  Future<Invoice?> get(int id);

  @floor.insert
  Future<int> insert(Invoice appointment);

  @floor.update
  Future<int> update(Invoice appointment);

  @floor.delete
  Future<int> remove(Invoice appointment);
}