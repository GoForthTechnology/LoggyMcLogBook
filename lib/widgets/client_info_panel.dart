import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/info_panel.dart';

class ClientInfoPanel extends StatelessWidget {
  final Client client;

  const ClientInfoPanel({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    // Her name, his name, reproductive category, client since date?
    return ExpandableInfoPanel(
      title: "Client Info",
      subtitle:
          "${client.firstName} ${client.lastName} & John Doe -- Category Foo",
      initiallyExpanded: false,
      contents: [
        Padding(padding: EdgeInsets.all(20), child: Text("Coming soon!")),
      ],
      trailing: TextButton(
          onPressed: () {
            AutoRouter.of(context)
                .push(ClientDetailsScreenRoute(clientId: client.id!));
          },
          child: Text("DETAILS")),
    );
  }
}
