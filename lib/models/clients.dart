
import 'package:flutter/cupertino.dart';
import 'package:lmlb/entities/client.dart';

class Clients extends ChangeNotifier {
  Map<int, Client> _clients = {};

  List<Client> get clients => _clients.values.toList();

  Client? get(int id) {
    return _clients[id];
  }

  void add(String firstName, String lastName) {
    final int id = _clients.length + 1;
    _clients[id] = Client(id, firstName, lastName);
    notifyListeners();
  }

  void update(Client client) {
    _clients[client.num] = client;
    notifyListeners();
  }

  void remove(Client client) {
    _clients.remove(client.num);
    notifyListeners();
  }
}