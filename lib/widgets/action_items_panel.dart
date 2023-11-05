
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/reminder.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/reminders.dart';
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
        if (snapshot.data?.num == null) {
          return ExpandableInfoPanel(
            title: "Action Items",
            subtitle: "",
            contents: [
              OverviewTile(
                attentionLevel: OverviewAttentionLevel.GREEN,
                title: "Assign Client Number",
                subtitle: "Assigning a client number will enable more functionality",
                icon: Icons.approval,
                actions: [
                  OverviewAction(title: "Assign", onPress: () => clientRepo.assignClientNum(snapshot.data!)),
                ],
              ),
            ],
            initiallyExpanded: true,
          );
        }
        return Consumer<Reminders>(builder: (context, repo, child) => StreamBuilder<List<Reminder>>(
          stream: repo.forClient(clientID!),
          builder: (context, snapshot) {
            if (snapshot.data?.isEmpty ?? true) {
              return ExpandableInfoPanel(
                title: "Action Items",
                subtitle: "Nothing for now :-)",
                contents: [],
              );
            }
            var reminders = snapshot.data!;
            return ExpandableInfoPanel(
              title: "Action Items",
              subtitle: "${reminders.length} outstanding",
              contents: reminders.map((r) => ActionItemTile.forReminder(r)).toList(),
              initiallyExpanded: true,
            );
          },
        ));
      },));
  }
}

class ActionItemTile {

  static OverviewTile forReminder(Reminder reminder) {
    var hasTriggered = reminder.triggerTime.isBefore(DateTime.now());
    List<OverviewAction> actions = [];
    String subtitle;
    if (hasTriggered) {
      actions = [
        OverviewAction(title: "SCHEDULE"),
        OverviewAction(title: "SNOOZE"),
        OverviewAction(title: "DISMISS"),
      ];
      subtitle = "${reminder.triggerTime.difference(DateTime.now()).inDays} days overdue!";
    } else {
      actions = [
        OverviewAction(title: "SCHEDULE"),
        OverviewAction(title: "DISMISS"),
      ];
      subtitle = "Snoozed until ${reminder.triggerTime}";
    }
    return OverviewTile(
      title: reminder.title,
      subtitle: subtitle,
      attentionLevel: hasTriggered ? OverviewAttentionLevel.YELLOW : OverviewAttentionLevel.GREY,
      icon: Icons.event,
      actions: actions,
    );
  }
}
