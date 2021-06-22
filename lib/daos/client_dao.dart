import 'package:floor/floor.dart';
import 'package:lmlb/entities/client.dart';

@dao
abstract class ClientDao {
  @Query('SELECT * FROM Client')
  Future<List<Client>> getAll();

  @Query('SELECT * FROM Client WHERE num = :num')
  Future<Client?> get(int num);

  @insert
  Future<void> insert(Client client);
}
