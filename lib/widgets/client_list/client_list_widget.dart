

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client_list_model.dart';

class ClientListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClientListData>(
      stream: Provider.of<ClientListModel>(context).data,
      initialData: new ClientListData([]),
      builder: (context, snapshot) {
        var clients = snapshot.data?.clientData ?? [];
        return ListView.builder(
          itemCount: clients.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) => ClientTile(clients[index]),
        );
      },
    );
  }
}

class ClientTile extends StatelessWidget {
  final ClientData client;

  ClientTile(this.client);

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        key: Key('client_text_${client.id}'),
        title: Text(client.tile),
        leading: ClientIconWidget(data: client.icon),
        onTap: () => Provider.of<ClientListModel>(context, listen: false).onClientTapped(context, client.id),
      ),
    ));
  }
}

class ClientIconWidget extends StatelessWidget {
  final ClientIcon data;

  const ClientIconWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: data.tooltip,
      child: CircleAvatar(
        backgroundColor: data.color,
      ),
    );
  }

}
