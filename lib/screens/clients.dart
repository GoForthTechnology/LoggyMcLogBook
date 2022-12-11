import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:provider/provider.dart';

class ClientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: Consumer<Clients>(
        builder: (context, model, child) => FutureBuilder<List<Client>>(
          future: model.getAll(),
          builder: (context, snapshot) {
            var clients = snapshot.data ?? [];
            return ListView.builder(
              itemCount: clients.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) => ClientTile(clients[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () => addClient(context),
      ),
    );
  }

  void addClient(BuildContext context) {
    AutoRouter.of(context).push(ClientDetailsScreenRoute())
        .then((updated) {
      if (updated as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Client added')));
      }
    });
  }
}

class ClientTile extends StatelessWidget {
  final Client client;

  ClientTile(
    this.client,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              client.id == null
                  ? Colors.black
                  : Colors.blue,
                  //: Colors.primaries[client.id! % Colors.primaries.length],
        ),
        title: Text(
          '${client.firstName} ${client.lastName} ${client.num == null ? "" : "#${client.displayNum()}"}',
          key: Key('client_text_${client.id}'),
        ),
        onTap: () {
          AutoRouter.of(context).push(ClientDetailsScreenRoute(clientId: client.id))
              .then((result) {
            if (result != null && result as bool) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Client updated')));
            }
          });
        },
      ),
    );
  }
}
