
import 'package:flutter/cupertino.dart';
import 'package:lmlb/database/daos/client_dao.dart';
import 'package:lmlb/entities/client.dart';

class Clients extends ChangeNotifier {
  ClientDao _clientDao;
  Map<int, Client> _clients = {};

  Clients(this._clientDao);

  Future<Clients> init() {
    return _clientDao.getAll().then((clients) {
      clients.forEach((client) => _clients[client.num!] = client);
      notifyListeners();
      return this;
    });
  }

  List<Client> getAll() {
    return _clients.values.toList();
  }

  Client? get(int id) {
    return _clients[id];
  }

  Future<void> add(String firstName, String lastName) {
    return _clientDao.insert(Client(null, firstName, lastName)).then((id) {
      _clients[id] = Client(id, firstName, lastName);
      notifyListeners();
    });
  }

  Future<void> update(Client client) {
    if (client.num == null) {
      return Future.error("Client missing id");
    }
    return _clientDao.update(client).then((_) {
      _clients[client.num!] = client;
      notifyListeners();
    });
  }

  Future<void> remove(Client client) {
    return _clientDao.remove(client).then((_) {
      _clients.remove(client.num);
      notifyListeners();
    });
  }
}