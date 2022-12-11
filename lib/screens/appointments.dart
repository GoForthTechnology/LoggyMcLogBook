import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:provider/provider.dart';

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

class AppointmentsScreen extends StatelessWidget {
  final Client? client;
  late View view;

  AppointmentsScreen({Key? key, this.client, @PathParam() required String view}) : super(key: key) {
    this.view = View.values.firstWhere((v) => v.name == view.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final hasClientFilter = client != null;
    return Scaffold(
      appBar: AppBar(
        title: !hasClientFilter
            ? const Text('Appointments')
            : Text("${client!.fullName()}'s Appointments"),
      ),
      body: Column(children: [
        buildHeader(context, view),
        Flexible(child: Consumer2<Appointments, Clients>(
            builder: (context, appointmentsModel, clientsModel, child) {
          final appointmentsF = appointmentsModel
              .get((a) => client == null || a.clientId == client?.id && view.predicate()(a))
              .then((as) => as.reversed.toList());
          final clientsF = clientsModel.getAll();

          return FutureBuilder(
            future: Future.wait([appointmentsF, clientsF]),
            builder: (context, snapshot) {
              List<Appointment> appointments = [];
              Map<String, Client> clients = {};
              if (snapshot.data != null) {
                final dataF = snapshot.data! as List<Object>;
                appointments.addAll(dataF[0] as List<Appointment>);
                (dataF[1] as List<Client>).forEach((client) {
                  clients[client.id!] = client;
                });
              }
              if (snapshot.data == null) {
                return Container();
              }
              return ListView.builder(
                  itemCount: appointments.length,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return AppointmentTile(
                      appointment,
                      clients[appointment.clientId]!,
                      hasClientFilter,
                     );
                  });
            }
          );
        })),
        buildFooter(context, view),
      ]),
      floatingActionButton: buildFab(context, view),
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

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final Client client;
  final bool hasClientFilter;

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
    final isInPast = appointment.time.isBefore(DateTime.now());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors
              .primaries[appointment.time.minute % Colors.primaries.length],
        ),
        title: Text(title, style: TextStyle(color: isInPast ? Colors.grey : Colors.black)),
        trailing: showDeleteButton ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            confirmDeletion(context, appointment);
          },
        ) : null,
        onTap: () {
          AutoRouter.of(context).push(AppointmentDetailScreenRoute(appointmentId: appointment.id, appointment: appointment))
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
