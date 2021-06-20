
import 'package:flutter/cupertino.dart';

class Clients extends ChangeNotifier {
  Map<int, Client> _clients = {};

  List<Client> get clients => _clients.values.toList();

  void add(String firstName, String lastName) {
    final int id = _clients.length + 1;
    _clients[id] = Client(id, firstName, lastName);
    notifyListeners();
  }

  void remove(Client client) {
    _clients.remove(client.num);
    notifyListeners();
  }
}

class Client {
  final int num;
  final String firstName;
  final String lastName;
  Client(
      this.num,
      this.firstName,
      this.lastName,
  );

  String fullName() {
    return "$firstName $lastName";
  }

  int displayNum() {
    return 010000 + num;
  }
}