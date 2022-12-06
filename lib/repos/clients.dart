
import 'package:flutter/cupertino.dart';
import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/entities/client.dart';

class Clients extends ChangeNotifier {
  CrudInterface<Client> _persistence;
  Map<String, Client> _clients = {};

  Clients(this._persistence);

  Future<Clients> init() {
    return _persistence.getAll().then((clients) {
      clients.forEach((client) => _clients[client.id!] = client);
      notifyListeners();
      return this;
    });
  }

  List<Client> getAll() {
    return _clients.values.toList();
  }

  Client? get(String id) {
    return _clients[id];
  }

  Future<void> add(String firstName, String lastName) {
    return _persistence.insert(Client(null, firstName, lastName)).then((id) {
      _clients[id] = Client(id, firstName, lastName);
      notifyListeners();
    });
  }

  Future<void> update(Client client) {
    if (client.id == null) {
      return Future.error("Client missing id");
    }
    return _persistence.update(client).then((_) {
      _clients[client.id!] = client;
      notifyListeners();
    });
  }

  Future<void> remove(Client client) {
    return _persistence.remove(client).then((_) {
      _clients.remove(client.id);
      notifyListeners();
    });
  }
}