import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/client_detail/client_detail_model.dart';
import 'package:lmlb/widgets/currency_selector.dart';
import 'package:lmlb/widgets/my_editable_text.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class ClientDetailsWidget extends StatelessWidget {
  final String clientID;

  const ClientDetailsWidget({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clientRepo, child) {
      List<Widget> contents = [
        Wrap(children: [
          ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: ClientBasicInfoWidget(clientID: clientID)),
          Column(children: [
            ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: ClientContactInfoWidget()),
            ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: ClientBillingInfoWidget()),
          ]),
        ],),
        Padding(padding: EdgeInsets.all(20), child: Row(
          children: [
            Text("Action Items", style: Theme.of(context).textTheme.titleLarge,),
            Spacer(),
            TextButton(onPressed: () {}, child: Text("Add New"))
          ],
        )),
        ListView(shrinkWrap: true, children: [
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.RED,
            title: "Overdue Bill",
            subtitle: "Invoice #01120 is 13 days overdue.",
            icon: Icons.receipt_long,
            actions: [
              OverviewAction("View"),
            ],
          ),
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.YELLOW,
            title: "Unbilled Appointment",
            subtitle: "FUP 2 on June 12 2023 has not yet been billed.",
            icon: Icons.receipt_long,
            actions: [
              OverviewAction("Create Invoice"),
            ],
          ),
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.GREY,
            title: "Schedule Next Appointment",
            subtitle: "Previous appointment was FUP 5 on May 8 2023",
            icon: Icons.event,
            actions: [
              OverviewAction("Schedule"),
            ],
          ),
        ]),
        Padding(padding: EdgeInsets.all(20), child: Row(
          children: [
            Text("Recent Notes", style: Theme.of(context).textTheme.titleLarge,),
            Spacer(),
            TextButton(onPressed: () {}, child: Text("Add New"))
          ],
        )),
        ListView(shrinkWrap: true, children: [
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.GREY,
            title: "FUP 2 Notes",
            subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            icon: Icons.note,
            actions: [
              OverviewAction("Edit"),
            ],
          ),
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.GREY,
            title: "FUP 1 Notes",
            subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            icon: Icons.note,
            actions: [
              OverviewAction("Edit"),
            ],
          ),
        ],)
      ];
      return ChangeNotifierProvider<ClientDetailModel>(create: (context) => ClientDetailModel(clientID, clientRepo), child: Expanded(child: ListView(children: contents)));
    });
  }
}

class ClientBasicInfoWidget extends StatelessWidget {
  final String clientID;

  const ClientBasicInfoWidget({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientDetailModel>(builder: (context, model, child) => StreamBuilder<Client?>(
      stream: model.clientStream(),
      builder: (context, snapshot) {
        return _InfoWidget(
          title: "Basic Info",
          contents: [
            EditorItem(
              itemName: "First Name",
              clientID: clientID,
              getItemValue: (client) => client.firstName,
              setItemValue: (client, value) => client.copyWith(firstName: value),
            ),
            EditorItem(
              itemName: "Last Name",
              clientID: clientID,
              getItemValue: (client) => client.lastName,
              setItemValue: (client, value) => client.copyWith(lastName: value),
            ),
            EditorItem(
              itemName: "Spouse Name",
              clientID: clientID,
              getItemValue: (client) => client.spouseName,
              setItemValue: (client, value) => client.copyWith(spouseName: value),
            ),
            InfoItem(
              itemName: "Next Appointment", itemValue: Text("Not Scheduled"),
            ),
            InfoItem(
              itemName: "Previous Appointment",
              itemValue: Text("FUP 5 on May 8 2023"),
            ),
            InfoItem(
              itemName: "Days Since Last Appointment",
              itemValue: Text("100"),
            ),
          ],
        );
      } ,
    ));
  }
}

class ClientBillingInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ExpandableInfoWidget(
      title: "Billing Info",
      subtitle: "\$40 per follow up",
      contents: [
        InfoItem(itemName: "Preferred Currency", itemValue: CurrencySelector()),
      ],
    );
  }
}

class ClientContactInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClientDetailModel>(builder: (context, model, child) => _ExpandableInfoWidget(
      title: "Contact Info",
      subtitle: "",
      contents: [
        /*EditorItem(itemName: "Email"),
        EditorItem(itemName: "Phone Number"),
        EditorItem(itemName: "Intention"),
        EditorItem(itemName: "Age"),
        Divider(),
        EditorItem(itemName: "Address"),
        EditorItem(itemName: "City"),
        EditorItem(itemName: "State"),
        EditorItem(itemName: "Zip"),
        EditorItem(itemName: "Country"),*/
      ],
    ));
  }
}

class InfoItem extends StatelessWidget {
  final String itemName;
  final Widget itemValue;

  const InfoItem({super.key, required this.itemName, required this.itemValue});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(2), child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("$itemName:", style: Theme.of(context).textTheme.titleMedium?.apply(fontWeightDelta: 2)),
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

  const EditorItem({super.key, required this.itemName, required this.clientID, required this.getItemValue, required this.setItemValue});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clientRepo, child) => InfoItem(
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

class _ExpandableInfoWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> contents;

  const _ExpandableInfoWidget({required this.title, required this.subtitle, required this.contents});

  @override
  Widget build(BuildContext context) {
    return Card(child: ExpansionTile(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text(subtitle),
      childrenPadding: EdgeInsets.symmetric(horizontal: 20),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: contents,
    ));
  }
}

class _InfoWidget extends StatelessWidget {
  final String title;
  final List<Widget> contents;

  const _InfoWidget({required this.title, required this.contents});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: EdgeInsets.all(20), child: ConstrainedBox(
      constraints: BoxConstraints(minWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          ...contents.map((w) => Padding(padding: EdgeInsets.symmetric(vertical: 4), child: w)),
        ],
      ),
    )));
  }
}
