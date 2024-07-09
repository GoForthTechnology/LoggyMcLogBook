import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/my_editable_text.dart';
import 'package:provider/provider.dart';

class ExpandableInfoPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> contents;
  final Widget? trailing;
  final bool initiallyExpanded;
  final double childrenHorizontalPadding;
  final TextStyle? titleStyle;

  const ExpandableInfoPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.contents,
    this.trailing,
    this.initiallyExpanded = false,
    this.childrenHorizontalPadding = 20,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    var tile = ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Text(title,
          style: titleStyle ?? Theme.of(context).textTheme.titleLarge),
      subtitle: subtitle == "" ? null : Text(subtitle),
      childrenPadding:
          EdgeInsets.symmetric(horizontal: childrenHorizontalPadding),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.topLeft,
      trailing: trailing,
      children: contents,
    );
    return Card(child: tile);
  }
}

class InfoPanel extends StatelessWidget {
  final String title;
  final List<Widget> contents;

  const InfoPanel({super.key, required this.title, required this.contents});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                ...contents.map((w) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: w)),
              ],
            )));
  }
}

class InfoItem extends StatelessWidget {
  final String itemName;
  final Widget itemValue;

  const InfoItem({super.key, required this.itemName, required this.itemValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("$itemName:",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.apply(fontWeightDelta: 2)),
            Container(width: 4),
            itemValue,
          ],
        ));
  }
}

class EditorItem extends StatelessWidget {
  final String clientID;
  final String itemName;
  final String Function(Client) getItemValue;
  final Client Function(Client, String) setItemValue;

  const EditorItem(
      {super.key,
      required this.itemName,
      required this.clientID,
      required this.getItemValue,
      required this.setItemValue});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
        builder: (context, clientRepo, child) => InfoItem(
              itemName: itemName,
              itemValue: MyEditableText(
                initialText: clientRepo.get(clientID).then((client) {
                  if (client == null) {
                    throw Exception("Client not found for ID $clientID");
                  }
                  return getItemValue(client);
                }),
                onSave: (value) => clientRepo.get(clientID).then((client) {
                  if (client == null) {
                    throw Exception("Client not found for ID $clientID");
                  }
                  return clientRepo.update(setItemValue(client, value));
                }),
                onError: (error) {
                  print("Got error: $error");
                },
              ),
            ));
  }
}
