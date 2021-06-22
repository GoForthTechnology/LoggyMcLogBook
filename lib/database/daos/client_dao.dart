import 'package:floor/floor.dart' as floor;
import 'package:lmlb/entities/client.dart';

@floor.dao
abstract class ClientDao {
  @floor.Query('SELECT * FROM Client')
  Future<List<Client>> getAll();

  @floor.Query('SELECT * FROM Client WHERE num = :num')
  Future<Client?> get(int num);

  @floor.insert
  Future<int> insert(Client client);

  @floor.update
  Future<void> update(Client client);

  @floor.delete
  Future<void> remove(Client client);
}
