
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

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
