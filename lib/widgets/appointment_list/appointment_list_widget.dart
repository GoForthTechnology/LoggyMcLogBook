import 'package:flutter/material.dart';
import 'package:lmlb/widgets/filter_bar.dart';
import 'package:lmlb/widgets/warning_widget.dart';
import 'package:provider/provider.dart';

import 'appointment_list_model.dart';

final _appointmentFilters = [
  Filter<AppointmentData>(
      label: "Past Appointments", predicate: (a) => a.isInPast),
  Filter<AppointmentData>(
      label: "Upcoming Appointments", predicate: (a) => !a.isInPast),
];

class AppointmentListWidget extends StatelessWidget {
  const AppointmentListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FilterableListView<AppointmentData>(
      itemStream: Provider.of<AppointmentListModel>(context)
          .data
          .map((ald) => ald.appointmentData),
      filters: _appointmentFilters,
      defaultSort: Sort<AppointmentData>(
          label: "By Date", comparator: (a, b) => a.time.compareTo(b.time)),
      buildTile: (a) => AppointmentTile(a, false),
    );
  }
}

class AppointmentTile extends StatelessWidget {
  final AppointmentData appointment;
  final bool hasClientFilter;

  const AppointmentTile(this.appointment, this.hasClientFilter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          // TODO: make this color blind accessible
          backgroundColor: appointment.circleColor,
        ),
        title: Text(appointment.title,
            style: TextStyle(color: appointment.textColor)),
        trailing: appointment.warnings.isNotEmpty
            ? WarningWidget(warnings: appointment.warnings)
            : null,
        onTap: () => Provider.of<AppointmentListModel>(context, listen: false)
            .onClientTapped(context, appointment.id, appointment.clientID),
      ),
    ));
  }
}
