import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

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

class _ViewModel {
  final List<_DecoratedAppointment> appointments;

  _ViewModel(this.appointments);

  static _ViewModel create(List<Appointment> appointments, Map<String, Client> clients, bool hasClientFilter) {
    print("_ViewModel.create");
    return _ViewModel(appointments.map((appointment) {
      var client = clients[appointment.clientId];
      if (client == null) {
        throw Exception("Could not find client for id: ${appointment.clientId}");
      }
      return _DecoratedAppointment.create(appointment, client, hasClientFilter);
    }).toList());
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
    print("rebuild appointments");
    final hasClientFilter = client != null;
    return Consumer2<Appointments, Clients>(builder: (context, appointmentRepo, clientRepo, child) {
      final appointmentsS = appointmentRepo
          .streamAll((a) => client == null || a.clientId == client?.id && view.predicate()(a))
          .doOnError((p0, p1) { print("ERROR getting appointments"); })
          .map((as) => as.reversed.toList());
      final clientsS = clientRepo
          .streamAll()
          .doOnError((p0, p1) { print("ERROR getting clients"); })
          .map(Clients.indexClients);

      final viewModelS = Rx.combineLatest2<List<Appointment>, Map<String, Client>, _ViewModel>(
          appointmentsS,
          clientsS,
          (appointments, clients) => _ViewModel.create(appointments, clients, hasClientFilter));
      return StreamProvider<_ViewModel>.value(value: viewModelS, initialData: _ViewModel([]), builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: !hasClientFilter
                ? const Text('Appointments')
                : Text("${client!.fullName()}'s Appointments"),
          ),
          body: Column(children: [
            buildHeader(context, view),
            Flexible(child: Consumer<_ViewModel>(
              builder: (context, viewModel, child) {
                print(viewModel);
                return ListView.builder(
                  itemCount: viewModel.appointments.length,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemBuilder: (context, index) {
                    final appointment = viewModel.appointments[index];
                    return AppointmentTile(appointment, hasClientFilter);
                  },
                );
              },
            )),
            buildFooter(context, view),
          ]),
          floatingActionButton: buildFab(context, view),
        );
      });
    });
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

class _DecoratedAppointment {
  final String title;
  final Color circleColor;
  final Color textColor;
  final String id;
  final bool isInPast;

  _DecoratedAppointment(this.title, this.circleColor, this.textColor, this.id, this.isInPast);

  static _DecoratedAppointment create(Appointment appointment, Client client, bool hasClientFilter) {
    var title = "${appointment.type.name()} ${appointment.timeStr()}";
    if (!hasClientFilter) {
      title = "${client.fullName()} - $title";
    }
    if (appointment.id == null) {
      throw Exception("Appointment ID cannot be null!");
    }
    final isInPast = appointment.time.isBefore(DateTime.now());
    final textColor = isInPast ? Colors.grey : Colors.black;
    return _DecoratedAppointment(title, appointment.status().color, textColor, appointment.id!, isInPast);
  }
}

class AppointmentTile extends StatelessWidget {
  final _DecoratedAppointment appointment;
  final bool hasClientFilter;

  AppointmentTile(
    this.appointment,
    this.hasClientFilter,
  );

  @override
  Widget build(BuildContext context) {
    final showDeleteButton = !hasClientFilter;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          // TODO: make this color blind accessible
          backgroundColor: appointment.circleColor,
        ),
        title: Text(appointment.title, style: TextStyle(color: appointment.textColor)),
        trailing: showDeleteButton ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            confirmDeletion(context, appointment);
          },
        ) : null,
        onTap: () {
          AutoRouter.of(context).push(AppointmentDetailScreenRoute(appointmentId: appointment.id))
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

  void confirmDeletion(BuildContext context, _DecoratedAppointment appointment) {
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
            .remove(appointment.id)
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
      content: Text("Would you like to remove ${appointment.title}?"),
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
