
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';

class ClientListModel extends ChangeNotifier {

  final Stream<ClientListData> data;
  final Function(BuildContext context, String? clientID) onClientTapped;

  ClientListModel({
    required this.onClientTapped,
    required Clients clients,
  }) : data = clients.streamAll().map((clients) => ClientListData.from(clients));
}

class ClientListData {
  final List<ClientData> clientData;

  ClientListData(this.clientData);

  static ClientListData from(List<Client> clients) {
    print("Found ${clients.length} clients");
    List<ClientData> data = [];
    for (var client in clients) {
      if (client.status() == ClientStatus.Prospective) {
        continue;
      }
      data.add(ClientData.from(client));
    }
    print("Parsed ${data.length} clients");
    return ClientListData(data);
  }
}

class ClientData {
  final String tile;
  final String? id;
  final ClientIcon icon;

  ClientData(this.tile, this.id, this.icon);

  static ClientData from(Client client) {
    var title = '${client.num == null ? "" : "#${client.displayNum()} - ${client.firstName} ${client.lastName}"}';
    return ClientData(title, client.id, ClientIcon.from(client));
  }
}

extension ClientStatusX on ClientStatus {
  String get tooltip {
    switch (this) {
      case ClientStatus.Prospective:
        return "Not yet a client";
      case ClientStatus.Active:
        return "Active client";
      case ClientStatus.Inactive:
        return "Inactive client";
    }
  }
  Color? get color {
    switch (this) {
      case ClientStatus.Prospective:
        return Colors.black;
      case ClientStatus.Active:
        return Colors.blue;
      case ClientStatus.Inactive:
        return Colors.grey;
    }
  }
}

class ClientIcon {
  final Color? color;
  final String? tooltip;

  ClientIcon(this.color, this.tooltip);

  static ClientIcon from(Client client) {
    return ClientIcon(client.status().color, client.status().tooltip);
  }
}
