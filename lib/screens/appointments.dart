import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/appointment_list/appointment_list_model.dart';
import 'package:lmlb/widgets/appointment_list/appointment_list_widget.dart';
import 'package:lmlb/widgets/navigation_rail.dart';

class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppointmentListModel.provide(
      clientFilter: null,
      onClientTapped: (context, appoinmentID, clientID) {
        AutoRouter.of(context)
            .push(AppointmentDetailScreenRoute(
                appointmentID: appoinmentID, clientID: clientID))
            .then((result) {
          if (result != null && result as bool) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('Client updated')));
          }
        });
      },
      child: NavigationRailScreen(
        item: NavigationItem.APPOINTMENTS,
        title: const Text('Appointments'),
        content: AppointmentListWidget(),
      ),
    );
  }

  Widget? buildFab(BuildContext context) {
    return FloatingActionButton(
      // isExtended: true,
      child: Icon(Icons.add),
      backgroundColor: Colors.green,
      // TODO: Re-enable
      //onPressed: () => addAppointment(context),
      onPressed: () {},
    );
  }
}
