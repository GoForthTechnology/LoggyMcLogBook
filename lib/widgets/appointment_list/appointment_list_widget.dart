

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appointment_list_model.dart';

class AppointmentListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppointmentListData>(
      stream: Provider.of<AppointmentListModel>(context).data,
      initialData: new AppointmentListData([]),
      builder: (context, snapshot) {
        var clients = snapshot.data?.appointmentData ?? [];
        print("FOO: found ${clients.length} clients");
        return ListView.builder(
          itemCount: clients.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) => AppointmentTile(clients[index], false),
        );
      },
    );
  }
}

class AppointmentTile extends StatelessWidget {
  final AppointmentData appointment;
  final bool hasClientFilter;

  AppointmentTile(
      this.appointment,
      this.hasClientFilter,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          // TODO: make this color blind accessible
          backgroundColor: appointment.circleColor,
        ),
        title: Text(appointment.title, style: TextStyle(color: appointment.textColor)),
        trailing: appointment.warnings.isNotEmpty ? WarningWidget(warnings: appointment.warnings) : null,
        onTap: () => Provider.of<AppointmentListModel>(context, listen: false).onClientTapped(context, appointment.id),
      ),
    );
  }
}

class WarningWidget extends StatelessWidget {
  final List<String> warnings;

  const WarningWidget({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) {
      return Container();
    }
    return Tooltip(message: warnings.join("\n"), child: Icon(Icons.warning));
  }
}


