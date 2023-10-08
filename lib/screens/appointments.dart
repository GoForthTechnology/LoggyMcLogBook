import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/appointment_list/appointment_list_model.dart';
import 'package:lmlb/widgets/appointment_list/appointment_list_widget.dart';

enum AppointmentListView { ALL, PENDING }

extension ViewExt on AppointmentListView {
  bool Function(Appointment) predicate() {
    switch (this) {
      case AppointmentListView.ALL:
        return (v) => true;
      case AppointmentListView.PENDING:
        return (v) => v.invoiceId == null;
      default:
        throw Exception("Unsupported View typel");
    }
  }
}

class AppointmentsScreen extends StatelessWidget {
  final Client? client;
  final AppointmentListView view;

  AppointmentsScreen({Key? key, this.client, @PathParam() required String view})
      : this.view = AppointmentListView.values.firstWhere((v) => v.name == view.toUpperCase()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasClientFilter = client != null;
    return AppointmentListModel.provide(
      clientFilter: null,
      onClientTapped: (context, id) {
        AutoRouter.of(context).push(AppointmentDetailScreenRoute(appointmentId: id))
            .then((result) {
          if (result != null && result as bool) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('Client updated')));
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: !hasClientFilter
              ? const Text('Appointments')
              : Text("${client!.fullName()}'s Appointments"),
        ),
        body: AppointmentListWidget(),
        floatingActionButton: buildFab(context, view),
      ),
    );
  }

  Widget? buildFab(BuildContext context, AppointmentListView view) {
    if (view == AppointmentListView.ALL) {
      return FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () => addAppointment(context),
      );
    }
    return null;
  }

  void addAppointment(BuildContext context) {
    AutoRouter.of(context).push(AppointmentDetailScreenRoute())
        .then((updated) {
      if (updated != null && updated as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Appointment added')));
      }
    });
  }
}


