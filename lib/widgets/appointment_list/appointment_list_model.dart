
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AppointmentListModel extends ChangeNotifier {

  final Stream<AppointmentListData> data;
  final Function(BuildContext context, String? clientID) onClientTapped;

  AppointmentListModel({
    required this.onClientTapped,
    required Appointments appointments,
    required Clients clients,
    required Client? clientFilter,
  }) : data = AppointmentListData.stream(appointments, clients, clientFilter);

  static Widget provide({
    required Function(BuildContext context, String? clientID) onClientTapped,
    required Client? clientFilter,
    required Widget child,
  }) {
    return Consumer2<Appointments, Clients>(
        builder: (context, appointmentRepo, clientRepo, c) =>
            ChangeNotifierProvider<AppointmentListModel>(
              create: (context) =>
                  AppointmentListModel(
                    appointments: appointmentRepo,
                    clients: clientRepo,
                    clientFilter: clientFilter,
                    onClientTapped: onClientTapped,
                  ),
              child: child,
            ));
  }
}

class AppointmentListData {
  final List<AppointmentData> appointmentData;

  AppointmentListData(this.appointmentData);

  static Stream<AppointmentListData> stream(Appointments appointmentRepo, Clients clientRepo, Client? clientFilter) {
    return Rx.combineLatest2(
        appointmentRepo.streamAll((a) => clientFilter == null || a.clientId == clientFilter.id),
        clientRepo.streamAll(),
        AppointmentListData.from);
  }

  static AppointmentListData from(List<Appointment> appointments, List<Client> clients) {
    Map<String, Client> clientIndex = {};
    for (var client in clients) {
      var clientID = client.id;
      if (clientID != null) {
        clientIndex[clientID] = client;
      }
    }
    List<AppointmentData> data = [];
    for (var appointment in appointments) {
      data.add(AppointmentData.create(appointment, clientIndex[appointment.clientId]!, false));
    }
    return AppointmentListData(data);
  }
}

class AppointmentData {
  final String title;
  final Color circleColor;
  final Color textColor;
  final String id;
  final bool isInPast;
  final List<String> warnings;

  AppointmentData(this.title, this.circleColor, this.textColor, this.id, this.isInPast, this.warnings);

  static AppointmentData create(Appointment appointment, Client client, bool hasClientFilter) {
    var title = "${appointment.type.name()} ${appointment.timeStr()}";
    if (!hasClientFilter) {
      title = "${client.fullName()} - $title";
    }
    if (appointment.id == null) {
      throw Exception("Appointment ID cannot be null!");
    }
    final isInPast = appointment.time.isBefore(DateTime.now());
    final textColor = isInPast ? Colors.grey : Colors.black;
    List<String> warnings = [];
    if (appointment.time.isBefore(DateTime.now()) && appointment.invoiceId == null) {
      warnings.add("Not yet invoiced");
    }
    return AppointmentData(title, appointment.status().color, textColor, appointment.id!, isInPast, warnings);
  }
}
