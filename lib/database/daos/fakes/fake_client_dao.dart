
import 'package:lmlb/database/daos/client_dao.dart';
import 'package:lmlb/entities/client.dart';

class FakeClientDao extends ClientDao {
  @override
  Future<Client?> get(int num) {
    return Future.value(null);
  }

  @override
  Future<List<Client>> getAll() {
    return Future.value(List.empty());
  }

  @override
  Future<int> insert(Client client) {
    return Future.value(0);
  }

  @override
  Future<void> remove(Client client) {
    return Future.value(null);
  }

  @override
  Future<void> update(Client client) {
    return Future.value(null);
  }
}