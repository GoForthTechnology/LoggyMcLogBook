
import 'package:flutter/cupertino.dart';

class Clients extends ChangeNotifier {
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  void add(Client client) {
    _clients.add(client);
    notifyListeners();
  }

  void remove(Client client) {
    _clients.remove(client);
    notifyListeners();
  }
}

class Client {
  int num;
  int firstName;
  int lastName;

  Client(
      this.num,
      this.firstName,
      this.lastName,
  );

  int displayNum() {
    return 010000 + num;
  }
}