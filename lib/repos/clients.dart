
import 'package:flutter/cupertino.dart';
import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/entities/client.dart';

class Clients extends ChangeNotifier {
  CrudInterface<Client> _persistence;
  Map<String, Client> _clients = {};

  Clients(this._persistence) {
    _persistence.addListener(() => init());
  }

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

  Future<void> add(String firstName, String lastName) async {
    var numClients = await _persistence.getAll().then((clients) => clients.length);
    var newClientNum = numClients + 1;
    var newClient = Client(null, newClientNum, firstName, lastName);
    return _persistence.insert(newClient).then((id) {
      _clients[id] = newClient.setId(id);
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