import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/client_detail/client_detail_model.dart';
import 'package:lmlb/widgets/currency_selector.dart';
import 'package:lmlb/widgets/gif_form.dart';
import 'package:lmlb/widgets/info_panel.dart';
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
          ClientBasicInfoWidget(clientID: clientID),
          /*Column(children: [
            ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: ClientContactInfoWidget(clientID: clientID,)),
            ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: ClientBillingInfoWidget()),
          ]),*/
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
          GifForm(),
        ],)
      ];
      return ChangeNotifierProvider<ClientDetailModel>(
        create: (context) => ClientDetailModel(clientID, clientRepo),
        child: ListView(children: contents),
      );
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
        return InfoPanel(
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
            /*EditorItem(
              itemName: "Spouse Name",
              clientID: clientID,
              getItemValue: (client) => client.spouseName ?? "",
              setItemValue: (client, value) => client.copyWith(spouseName: value),
            ),*/
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
    return ExpandableInfoPanel(
      title: "Billing Info",
      subtitle: "\$40 per follow up",
      contents: [
        InfoItem(itemName: "Preferred Currency", itemValue: CurrencySelector()),
      ],
    );
  }
}

class ClientContactInfoWidget extends StatelessWidget {
  final String clientID;

  const ClientContactInfoWidget({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientDetailModel>(builder: (context, model, child) => ExpandableInfoPanel(
      title: "Contact Info",
      subtitle: "",
      contents: [
        //EditorItem(itemName: "Intention"),
        //EditorItem(itemName: "Age"),
        /*EditorItem(
          itemName: "Email",
          clientID: clientID,
          getItemValue: (client) => client.email ?? "",
          setItemValue: (client, value) => client.copyWith(email: value),
        ),
        EditorItem(
          itemName: "Phone Number",
          clientID: clientID,
          getItemValue: (client) => client.phoneNumber ?? "",
          setItemValue: (client, value) => client.copyWith(phoneNumber: value),
        ),
        Divider(),
        EditorItem(
          itemName: "Address",
          clientID: clientID,
          getItemValue: (client) => client.address ?? "",
          setItemValue: (client, value) => client.copyWith(address: value),
        ),
        EditorItem(
          itemName: "City",
          clientID: clientID,
          getItemValue: (client) => client.city ?? "",
          setItemValue: (client, value) => client.copyWith(city: value),
        ),
        EditorItem(
          itemName: "State",
          clientID: clientID,
          getItemValue: (client) => client.state ?? "",
          setItemValue: (client, value) => client.copyWith(state: value),
        ),
        EditorItem(
          itemName: "ZIP",
          clientID: clientID,
          getItemValue: (client) => client.zip ?? "",
          setItemValue: (client, value) => client.copyWith(zip: value),
        ),
        EditorItem(
          itemName: "Country",
          clientID: clientID,
          getItemValue: (client) => client.country ?? "",
          setItemValue: (client, value) => client.copyWith(country: value),
        ),*/
      ],
    ));
  }
}
