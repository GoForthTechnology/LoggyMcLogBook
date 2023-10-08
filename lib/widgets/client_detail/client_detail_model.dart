
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';

class ClientDetailModel extends ChangeNotifier {
  final String _clientID;
  final Clients _clientRepo;

  ClientDetailModel(this._clientID, this._clientRepo);

  Stream<Client?> clientStream() {
    return _clientRepo.stream(_clientID);
  }

  Future<void> updateFirstName(String value) {
    return _updateField((c) => c.copyWith(firstName: value));
  }

  Future<void> _updateField(Client Function(Client) update) {
    return _clientRepo.get(_clientID).then((client) {
      if (client == null) {
        throw Exception("No client found for client ID $_clientID");
      }
      return _clientRepo.update(update(client));
    });
  }
}

class ClientDetailData {
  final Client client;

  ClientDetailData({required this.client});
}