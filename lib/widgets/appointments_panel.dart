import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/new_appointment_dialog.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class AppointmentsPanel extends StatelessWidget {
  final String? clientID;

  const AppointmentsPanel({super.key, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Appointments>(
      builder: (context, repo, child) => StreamBuilder<List<Appointment>>(
          stream: repo.streamAll((a) => true, clientID: clientID),
          builder: (context, snapshot) {
            List<Appointment> appointments = snapshot.data ?? [];
            List<Appointment> sortedAppointments = List.from(appointments);
            sortedAppointments.sort((a, b) => b.time.compareTo(a.time));
            return ExpandableInfoPanel(
              title: "Appointments",
              subtitle: _subtitle(sortedAppointments),
              initiallyExpanded: false,
              contents: sortedAppointments
                  .map((a) => _appointmentTile(context, a))
                  .toList(),
              trailing: TextButton(
                child: Text("Add Next"),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => NewAppointmentDialog(
                    clientID: clientID!,
                  ),
                ),
              ),
            );
          }),
    );
  }

  String _subtitle(List<Appointment> appointments) {
    List<Appointment> sortedAppointments = List.from(appointments);
    sortedAppointments.sort((a, b) => a.time.compareTo(b.time));
    var previousAppointments =
        sortedAppointments.where((a) => a.time.isBefore(DateTime.now()));
    var nextAppointments =
        sortedAppointments.where((a) => a.time.isAfter(DateTime.now()));
    List<String> parts = [];
    if (previousAppointments.isNotEmpty) {
      parts.add("Previous ${previousAppointments.last.toString()}");
    }
    if (nextAppointments.isNotEmpty) {
      parts.add("Next ${nextAppointments.first.toString()}");
    }
    if (parts.isNotEmpty) {
      return parts.join(", ");
    }
    return "No appointments scheduled";
  }

  Widget _appointmentTile(BuildContext context, Appointment a) {
    return OverviewTile(
      attentionLevel: a.time.isBefore(DateTime.now())
          ? OverviewAttentionLevel.grey
          : OverviewAttentionLevel.green,
      title: a.type.name(),
      subtitle: a.timeStr(),
      icon: Icons.event,
      actions: [
        OverviewAction(
            title: "View",
            onPress: () => AutoRouter.of(context).push(
                AppointmentDetailScreenRoute(
                    appointmentID: a.id!, clientID: a.clientId))),
      ],
    );
  }
}
