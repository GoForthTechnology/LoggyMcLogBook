
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/new_appointment_dialog.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

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
