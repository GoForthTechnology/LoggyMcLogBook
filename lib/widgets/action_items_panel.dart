import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/ai_repo.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

extension NextStepActionExt on NextStepAction {
  String get label {
    switch (this) {
      case NextStepAction.addAppointmentToPendingInvoice:
        return "Add to Invoice";
      case NextStepAction.addAppointmentToNewInvoice:
        return "Create new Invoice";
      case NextStepAction.scheduleReminder:
        return "SCHEDULE";
      case NextStepAction.snoozeReminder:
        return "SNOOZE";
      case NextStepAction.dismissReminder:
        return "DISMISS";
      case NextStepAction.assignClientNum:
        return "ASSIGN";
    }
  }
}

extension ActionItemSeverityExt on ActionItemSeverity {
  OverviewAttentionLevel get attentionLevel {
    switch (this) {
      case ActionItemSeverity.urgent:
        return OverviewAttentionLevel.RED;
      case ActionItemSeverity.warning:
        return OverviewAttentionLevel.YELLOW;
      case ActionItemSeverity.info:
        return OverviewAttentionLevel.GREY;
      case ActionItemSeverity.encourage:
        return OverviewAttentionLevel.GREEN;
    }
  }
}

extension ActionItemCategoryExt on ActionItemCategory {
  IconData get icon {
    switch (this) {
      case ActionItemCategory.billing:
        return Icons.receipt_long;
      case ActionItemCategory.onboarding:
        return Icons.approval;
      case ActionItemCategory.reminder:
        return Icons.event;
    }
  }
}

class ActionItemsPanel extends StatelessWidget {
  final String? clientID;

  const ActionItemsPanel({super.key, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActionItemRepo>(
      builder: (context, aiRepo, child) => StreamBuilder<List<ActionItem>>(
        stream: aiRepo.getActionItems(clientID: clientID!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var actionItems = snapshot.data!;
          if (actionItems.isEmpty) {
            return const ExpandableInfoPanel(
              title: "Action Items",
              subtitle: "Nothing for now :-)",
              contents: [],
            );
          }
          var items = actionItems
              .map((ai) => OverviewTile(
                  attentionLevel: ai.severity.attentionLevel,
                  title: ai.title,
                  subtitle: ai.subtitle,
                  icon: ai.category.icon,
                  actions: ai.actions
                      .map((a) => OverviewAction(
                          title: a.label,
                          onPress: () async {
                            var messenger = ScaffoldMessenger.of(context);
                            var message = await aiRepo.handleAction(ai, a);
                            var snackBar = SnackBar(content: Text(message));
                            messenger.showSnackBar(snackBar);
                          }))
                      .toList()))
              .toList();
          return ExpandableInfoPanel(
              title: "Action Items",
              subtitle: "${actionItems.length} outstanding",
              contents: items,
              initiallyExpanded: true);
        },
      ),
    );
  }

  void createInvoice(BuildContext context, Invoices invoiceRepo, Client client,
      List<Appointment> unbilledAppointments) async {
    var messenger = ScaffoldMessenger.of(context);
    try {
      await invoiceRepo.create(clientID!, client,
          appointments: unbilledAppointments);
      var snackBar = SnackBar(
        content: const Text('Invoice Created'),
        action: SnackBarAction(label: "View", onPressed: () {}),
      );
      messenger.showSnackBar(snackBar);
    } catch (e) {
      var snackBar = SnackBar(
        content: Text(e.toString()),
      );
      messenger.showSnackBar(snackBar);
    }
  }
}
