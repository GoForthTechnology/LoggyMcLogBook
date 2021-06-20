
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lmlb/models/clients.dart';
import 'package:lmlb/screens/client.dart';

class ClientsScreen extends StatelessWidget {
  static const routeName = '/clients';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: Consumer<Clients>(
        builder: (context, value, child) => ListView.builder(
          itemCount: value.clients.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) => ClientTile(value.clients[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.of(context).pushNamed(ClientScreen.routeName, arguments: ClientScreenArguments(null));
        },
      ),
    );
  }
}

class ClientTile extends StatelessWidget {
  Client client;

  ClientTile(
      this.client,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.primaries[client.num % Colors.primaries.length],
        ),
        title: Text(
          '${client.firstName} ${client.lastName}',
          key: Key('client_text_${client.num}'),
        ),
        trailing: IconButton(
          key: Key('remove_icon_${client.num}'),
          icon: const Icon(Icons.close),
          onPressed: () {
            Provider.of<Clients>(context, listen: false).remove(client);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Removed client.'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}

