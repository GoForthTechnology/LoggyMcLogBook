import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/currency_selector.dart';
import 'package:lmlb/widgets/gif_form.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/new_appointment_dialog.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class ClientDetailsWidget extends StatelessWidget {
  final String clientID;

  const ClientDetailsWidget({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Wrap(children: [
        ClientBasicInfoWidget(clientID: clientID),
      ],),
      ActionItemsPanel(clientID: clientID,),
      AppointmentsPanel(clientID: clientID,),
      NotesPanel(clientID: clientID,),
      GifForm(),
    ]);
  }
}

class AppointmentsPanel extends StatelessWidget {
  final String? clientID;

  const AppointmentsPanel({super.key, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Appointments>(builder: (context, repo, child) => StreamBuilder<List<Appointment>>(
        stream: repo.streamAll((a) => a.clientId == clientID),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          var numAppointments = snapshot.data!.length;
          return ExpandableInfoPanel(
            title: "Appointments",
            subtitle: numAppointments == 0 ? "None Scheduled" : "Next on... TODO",
            initiallyExpanded: false,
            contents: snapshot.data!.map((a) => OverviewTile(
              attentionLevel: OverviewAttentionLevel.GREY,
              title: a.type.name(),
              subtitle: a.timeStr(),
              icon: Icons.event,
              actions: [
                OverviewAction(title: "View"),
              ],
            )).toList(),
            trailing: TextButton(
              child: Text("Add Next"),
              onPressed: () => showDialog(
                context: context, builder: (context) => NewAppointmentDialog(clientID: clientID!,),
              ),
            ),
          );
        }));
  }
}

class NotesPanel extends StatelessWidget {
  final String? clientID;

  const NotesPanel({super.key, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clientRepo, child) => FutureBuilder<Client?>(
      future: clientRepo.get(clientID!),
      builder: (context, snapshot) {
        if (snapshot.data?.num == null) {
          return Container();
        }
        return ExpandableInfoPanel(
          title: "Notes",
          subtitle: "",
          initiallyExpanded: false,
          contents: [
            OverviewTile(
              attentionLevel: OverviewAttentionLevel.GREY,
              title: "FUP 2 Notes",
              subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              icon: Icons.note,
              actions: [
                OverviewAction(title: "Edit"),
              ],
            ),
            OverviewTile(
              attentionLevel: OverviewAttentionLevel.GREY,
              title: "FUP 1 Notes",
              subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              icon: Icons.note,
              actions: [
                OverviewAction(title: "Edit"),
              ],
            ),
          ],
        );
      }));
  }
}

class ActionItemsPanel extends StatelessWidget {
  final String? clientID;

  const ActionItemsPanel({super.key, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clientRepo, child) => FutureBuilder<Client?>(
      future: clientRepo.get(clientID!),
      builder: (context, snapshot) {
        List<Widget> actionItems;
        if (snapshot.data?.num == null) {
          actionItems = [
            OverviewTile(
              attentionLevel: OverviewAttentionLevel.GREEN,
              title: "Assign Client Number",
              subtitle: "Assigning a client number will enable more functionality",
              icon: Icons.approval,
              actions: [
                OverviewAction(title: "Assign", onPress: () => clientRepo.assignClientNum(snapshot.data!)),
              ],
            ),
          ];
        } else {
          actionItems = [
            OverviewTile(
              attentionLevel: OverviewAttentionLevel.RED,
              title: "Overdue Bill",
              subtitle: "Invoice #01120 is 13 days overdue.",
              icon: Icons.receipt_long,
              actions: [
                OverviewAction(title: "View"),
              ],
            ),
            OverviewTile(
              attentionLevel: OverviewAttentionLevel.YELLOW,
              title: "Unbilled Appointment",
              subtitle: "FUP 2 on June 12 2023 has not yet been billed.",
              icon: Icons.receipt_long,
              actions: [
                OverviewAction(title: "Create Invoice"),
              ],
            ),
          ];
        }
        return ExpandableInfoPanel(title: "Action Items", subtitle: "", contents: actionItems, initiallyExpanded: true);
      },));
  }
}

class ClientBasicInfoWidget extends StatelessWidget {
  final String clientID;

  const ClientBasicInfoWidget({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
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
