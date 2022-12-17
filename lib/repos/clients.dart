
import 'package:flutter/cupertino.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/entities/client.dart';

class Clients extends ChangeNotifier {
  CrudInterface<Client> _persistence;

  Clients(this._persistence) {
    _persistence.addListener(() => init());
  }

  Future<Clients> init() async {
    return this;
  }

  Future<List<Client>> getAll() async {
    return _persistence.getAll();
  }

  Future<Map<String, Client>> getAllIndexed() async {
    return _persistence.getAll().then((clients) {
      Map<String, Client> index = {};
      clients.forEach((client) {
        if (client.id == null) {
          return;
        }
        index[client.id!] = client;
      });
      return index;
    });
  }

  Future<Client?> get(String id) {
    return _persistence.get(id);
  }

  Future<Client?> getForNum(int? clientNum) async {
    if (clientNum == null) {
      return null;
    }
    var clients = await getAll();
    return clients.firstWhere((client) => client.num == clientNum, orElse: null);
  }

  Future<void> add(String firstName, String lastName, Currency currency) async {
    var newClient = Client(null, null, firstName, lastName, currency, true);
    return _persistence.insert(newClient).then((id) {
      notifyListeners();
    });
  }

  Future<void> assignClientNum(Client client) async {
    var maxClientNum = 0;
    var clients = await _persistence.getAll();
    clients.forEach((client) {
      if (client.num == null) {
        return;
      }
      if (client.num! > maxClientNum) {
        maxClientNum = client.num!;
      }
    });
    return _persistence.update(client.assignNum(maxClientNum + 1))
        .then((_) => notifyListeners());
  }

  Future<void> activate(Client client) {
    return _persistence.update(client.setActive(true)).then((_) => notifyListeners());
  }

  Future<void> deactivate(Client client) {
    return _persistence.update(client.setActive(false)).then((_) => notifyListeners());
  }

  Future<void> update(Client client) {
    if (client.id == null) {
      return Future.error("Client missing id");
    }
    return _persistence.update(client).then((_) {
      notifyListeners();
    });
  }

  Future<void> remove(Client client) {
    return _persistence.remove(client).then((_) {
      notifyListeners();
    });
  }
}