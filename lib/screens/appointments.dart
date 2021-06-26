import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/screens/appointment_info.dart';
import 'package:provider/provider.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/screens/client_info.dart';

enum View { ALL, PENDING }

extension ViewExt on View {
  bool Function(Appointment) predicate() {
    switch (this) {
      case View.ALL:
        return (v) => true;
      case View.PENDING:
        return (v) => v.invoiceId == null;
      default:
        throw Exception("Unsupported View typel");
    }
  }
}

class AppointmentsScreenArguments {
  final Client? client;
  final View view;

  AppointmentsScreenArguments(this.client, this.view);
}

class AppointmentsScreen extends StatelessWidget {
  static const routeName = '/appointments';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as AppointmentsScreenArguments;
    final hasClientFilter = args.client != null;
    return Scaffold(
      appBar: AppBar(
        title: !hasClientFilter
            ? const Text('Appointments')
            : Text("${args.client!.fullName()}'s Appointments"),
      ),
      body: Column(children: [
        buildHeader(context, args.view),
        Flexible(child: Consumer2<Appointments, Clients>(
            builder: (context, appointmentsModel, clientsModel, child) {
          final appointments = appointmentsModel.get(
              sorted: true,
              clientId: args.client?.num,
              predicate: args.view.predicate()).reversed.toList();
          return ListView.builder(
              itemCount: appointments.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return AppointmentTile(
                  appointment,
                  clientsModel.get(appointment.clientId)!,
                  hasClientFilter,
                );
              });
        })),
        buildFooter(context, args.view),
      ]),
      floatingActionButton: buildFab(context, args.view),
    );
  }

  Widget? buildFab(BuildContext context, View view) {
    if (view == View.ALL) {
      return FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () => addAppointment(context),
      );
    }
    return null;
  }

  Widget buildHeader(BuildContext context, View view) {
    if (view == View.PENDING) {
      return Container(
          margin: EdgeInsets.only(top: 20.0),
          child: Text(
            "Pending invoice",
            style: TextStyle(fontStyle: FontStyle.italic),
          ));
    }
    return Container();
  }

  Widget buildFooter(BuildContext context, View view) {
    if (view == View.PENDING) {
      return Container(
        margin: EdgeInsets.only(bottom: 40.0),
        child: ElevatedButton(
          child: Text("Add to New Invoice"),
          onPressed: () {},
        ),
      );
    }
    return Container();
  }

  void addAppointment(BuildContext context) {
    Navigator.of(context)
        .pushNamed(AppointmentInfoScreen.routeName,
            arguments: AppointmentInfoScreenArguments(null))
        .then((updated) {
      if (updated != null && updated as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Appointment added')));
      }
    });
  }
}

class AppointmentTile extends StatelessWidget {
  Appointment appointment;
  Client client;
  bool hasClientFilter;

  AppointmentTile(
    this.appointment,
    this.client,
    this.hasClientFilter,
  );

  @override
  Widget build(BuildContext context) {
    var title = "${appointment.type.name()} ${appointment.timeStr()}";
    if (!hasClientFilter) {
      title = "${client.fullName()} - $title";
    }
    final showDeleteButton = !hasClientFilter;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors
              .primaries[appointment.time.minute % Colors.primaries.length],
        ),
        title: Text(title),
        trailing: showDeleteButton ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            confirmDeletion(context, appointment);
          },
        ) : null,
        onTap: () {
          Navigator.of(context)
              .pushNamed(AppointmentInfoScreen.routeName,
                  arguments: AppointmentInfoScreenArguments(appointment))
              .then((result) {
            if (result != null && result as bool) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Client updated')));
            }
          });
        },
      ),
    );
  }

  void confirmDeletion(BuildContext context, Appointment appointment) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
        Provider.of<Appointments>(context, listen: false)
            .remove(appointment)
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed client.'),
              duration: Duration(seconds: 1),
            ),
          );
        });
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm Deletion"),
      content: Text("Would you like to remove ${client.fullName()}?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
