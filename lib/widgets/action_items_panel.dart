import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/reminder.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/repos/reminders.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ActionItemsPanel extends StatelessWidget {
  final String? clientID;

  const ActionItemsPanel({super.key, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
        builder: (context, clientRepo, child) => FutureBuilder<Client?>(
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
                        subtitle:
                            "Assigning a client number will enable more functionality",
                        icon: Icons.approval,
                        actions: [
                          OverviewAction(
                              title: "Assign",
                              onPress: () =>
                                  clientRepo.assignClientNum(snapshot.data!)),
                        ],
                        comparable: "",
                      ),
                    ],
                    initiallyExpanded: true,
                  );
                }
                return Consumer3<Reminders, Appointments, Invoices>(
                    builder:
                        (context, reminders, appointments, invoices, child) =>
                            StreamBuilder<List<OverviewTile>>(
                              stream: actionItemTiles(
                                  context, reminders, appointments, invoices),
                              builder: (context, snapshot) {
                                if (snapshot.data?.isEmpty ?? true) {
                                  return ExpandableInfoPanel(
                                    title: "Action Items",
                                    subtitle: "Nothing for now :-)",
                                    contents: [],
                                  );
                                }
                                var items = snapshot.data!;
                                items.sort((a, b) => a.compareTo(b));
                                return ExpandableInfoPanel(
                                  title: "Action Items",
                                  subtitle: "${items.length} outstanding",
                                  contents: items,
                                  initiallyExpanded: true,
                                );
                              },
                            ));
              },
            ));
  }

  Stream<List<OverviewTile>> actionItemTiles(BuildContext context,
      Reminders reminders, Appointments appointments, Invoices invoices) {
    return Rx.combineLatest2<List<OverviewTile>, List<OverviewTile>,
            List<OverviewTile>>(
        reminders
            .forClient(clientID!)
            .map((rs) => rs.map((r) => ActionItemTile.forReminder(r)).toList()),
        appointments.streamAll((a) => true, clientID: clientID).map((as) => as
            .map((r) => ActionItemTile.forUnbilledAppointment(r,
                onCreateInvoice: () => createInvoice(context, invoices, as)))
            .toList()),
        (reminderActions, appointmentActions) =>
            [reminderActions, appointmentActions].expand((x) => x).toList());
  }

  void createInvoice(BuildContext context, Invoices invoices,
      List<Appointment> unbilledAppointments) async {
    try {
      var invoiceID = await invoices.create(clientID!, Currency.USD);
      print("Added ID: $invoiceID");
      var snackBar = SnackBar(
        content: Text('Invoice Created'),
        action: SnackBarAction(label: "View", onPressed: () {}),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      var snackBar = SnackBar(
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class ActionItemTile {
  static OverviewTile forUnbilledAppointment(Appointment appointment,
      {required Function() onCreateInvoice}) {
    int daysSinceAppointment =
        DateTime.now().difference(appointment.time).inDays;
    return OverviewTile(
      title: "Unbilled Appointment",
      subtitle: appointment.toString(),
      attentionLevel: daysSinceAppointment < 0
          ? OverviewAttentionLevel.GREY
          : daysSinceAppointment > 30
              ? OverviewAttentionLevel.RED
              : OverviewAttentionLevel.YELLOW,
      icon: Icons.event,
      actions: [
        OverviewAction(
            title: "CREATE INVOICE", onPress: () => onCreateInvoice())
      ],
      comparable: appointment.time,
    );
  }

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
      subtitle =
          "${reminder.triggerTime.difference(DateTime.now()).inDays} days overdue!";
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
      attentionLevel: hasTriggered
          ? OverviewAttentionLevel.YELLOW
          : OverviewAttentionLevel.GREY,
      icon: Icons.event,
      actions: actions,
      comparable: reminder.triggerTime,
    );
  }
}
