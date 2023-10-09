
import 'package:flutter/cupertino.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class Clients extends ChangeNotifier {
  StreamingCrudInterface<Client> _persistence;

  Clients(this._persistence) {
    _persistence.addListener(() => init());
  }

  Future<Clients> init() async {
    return this;
  }

  Future<List<Client>> getAll() async {
    return _persistence.getAll().first.onError((error, stackTrace) {
      print("Error getting Clients: $error");
      return [];
    });
  }

  Future<Map<String, Client>> getAllIndexed() async {
    return _persistence.getAll().first.then(indexClients);
  }

  Stream<List<Client>> streamAll() {
    return _persistence.getAll();
  }

  static Map<String, Client> indexClients(List<Client> clients) {
    Map<String, Client> index = {};
    clients.forEach((client) {
      if (client.id == null) {
        return;
      }
      index[client.id!] = client;
    });
    return index;
  }

  Future<Client?> get(String id) {
    return stream(id).first;
  }

  Stream<Client?> stream(String id) {
    return _persistence.get(id);
  }

  Future<Client?> getForNum(int? clientNum) async {
    if (clientNum == null) {
      return null;
    }
    var clients = await getAll();
    return clients.firstWhere((client) => client.num == clientNum, orElse: null);
  }

  Future<Client> newClient(Client client) async {
    if (client.id != null) {
      throw Exception("New clients cannot have IDs already assigned ${client.id}");
    }
    return _persistence.insert(client).then((id) => client.setId(id));
  }

  Future<void> assignClientNum(Client client) async {
    var maxClientNum = 0;
    var clients = await _persistence.getAll().first;
    clients.forEach((client) {
      if (client.num == null) {
        return;
      }
      if (client.num! > maxClientNum) {
        maxClientNum = client.num!;
      }
    });
    return _persistence.update(client.copyWith(num: maxClientNum + 1))
        .then((_) => notifyListeners());
  }

  Future<void> activate(Client client) {
    return _persistence.update(client.copyWith(active: true)).then((_) => notifyListeners());
  }

  Future<void> deactivate(Client client) {
    return _persistence.update(client.copyWith(active: false)).then((_) => notifyListeners());
  }

  Future<void> update(Client client) {
    if (client.id == null) {
      return Future.error("Client missing id");
    }
    return _persistence.update(client).then((_) {
      notifyListeners();
    });
  }

  Future<void> remove(Client client) async {
    final id = client.getId();
    if (id == null) {
      throw Exception("Null client id for $client");
    }
    await _persistence.remove(id);
    notifyListeners();
  }
}