import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/models/reproductive_category_model.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:provider/provider.dart';

class ClientInfoPanel extends StatelessWidget {
  final Client client;

  const ClientInfoPanel({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    // Her name, his name, reproductive category, client since date?
    return Consumer<ReproductiveCategoryModel>(
        builder: (context, model, child) => StreamBuilder<String>(
              stream: model.entries(client.id!).map((entries) {
                if (entries.isEmpty) {
                  return "unknown";
                }
                entries.sort(
                  (a, b) => b.sinceDate.compareTo(a.sinceDate),
                );
                return entries.first.category.name;
              }),
              builder: (context, categoryName) => ExpandableInfoPanel(
                title: "Client Info",
                subtitle:
                    "${client.firstName} ${client.lastName} & John Doe -- Category ${categoryName.data ?? ""}",
                initiallyExpanded: false,
                contents: [
                  Padding(
                      padding: EdgeInsets.all(20), child: Text("Coming soon!")),
                ],
                trailing: TextButton(
                    onPressed: () {
                      AutoRouter.of(context)
                          .push(ClientDetailsScreenRoute(clientId: client.id!));
                    },
                    child: Text("DETAILS")),
              ),
            ));
  }
}
