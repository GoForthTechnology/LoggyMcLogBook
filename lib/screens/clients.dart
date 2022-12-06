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
        builder: (context, model, child) => ListView.builder(
          itemCount: model.getAll().length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) => ClientTile(model.getAll()[index]),
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
    AutoRouter.of(context).push(ClientInfoScreenRoute())
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
              client.num == null
                  ? Colors.black
                  : Colors.primaries[client.num! % Colors.primaries.length],
        ),
        title: Text(
          '${client.firstName} ${client.lastName}',
          key: Key('client_text_${client.num}'),
        ),
        trailing: IconButton(
          key: Key('remove_icon_${client.num}'),
          icon: const Icon(Icons.close),
          onPressed: () {
            confirmDeletion(context, client);
          },
        ),
        onTap: () {
          AutoRouter.of(context).push(ClientInfoScreenRoute(client: client))
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

  void confirmDeletion(BuildContext context, Client client) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
        Provider.of<Clients>(context, listen: false).remove(client);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed client.'),
            duration: Duration(seconds: 1),
          ),
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm Deletion"),
      content: Text("Would you like to remove ${client.fullName()}?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
