import 'package:flutter/material.dart';
import 'package:lmlb/models/clients.dart';

class ClientScreenArguments {
  final Client? client;

  ClientScreenArguments(this.client);
}

class ClientScreen extends StatelessWidget {
  static const routeName = '/client';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ClientScreenArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.client == null ? 'New Client' : 'Client Info'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text("First Name:"),
              Text("TBD"),
            ],
          ),
          Row(
            children: [
              Text("Last Name:"),
              Text("TBD"),
            ],
          )
        ],
      ),
    );
  }
}
