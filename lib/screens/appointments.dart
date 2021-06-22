import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/screens/appointment_info.dart';
import 'package:provider/provider.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/screens/client_info.dart';

class AppointmentsScreen extends StatelessWidget {
  static const routeName = '/appointments';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: Consumer2<Appointments, Clients>(
          builder: (context, appointmentsModel, clientsModel, child) {
        final appointments = appointmentsModel.get(sorted: true);
        return ListView.builder(
            itemCount: appointments.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AppointmentTile(
                appointment,
                clientsModel.get(appointment.clientId)!,
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () => addAppointment(context),
      ),
    );
  }

  void addAppointment(BuildContext context) {
    Navigator.of(context)
        .pushNamed(AppointmentInfoScreen.routeName,
            arguments: AppointmentInfoScreenArguments(null))
        .then((updated) {
      if (updated as bool) {
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

  AppointmentTile(
    this.appointment,
    this.client,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors
              .primaries[appointment.time.minute % Colors.primaries.length],
        ),
        title: Text(
          '${client.fullName()} ${appointment.time}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            confirmDeletion(context, appointment);
          },
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed(ClientInfoScreen.routeName,
                  arguments: ClientInfoScreenArguments(client))
              .then((result) {
            if (result as bool) {
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
