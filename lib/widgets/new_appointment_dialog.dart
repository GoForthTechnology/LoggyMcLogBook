
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:provider/provider.dart';

class NewAppointmentDialog extends StatefulWidget {
  final String clientID;

  const NewAppointmentDialog({super.key, required this.clientID});

  @override
  State<StatefulWidget> createState() => _NewAppointmentDialogState();
}

class _NewAppointmentDialogState extends State<NewAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentTimeController = TextEditingController();
  final _appointmentDateController = TextEditingController();

  AppointmentType? _appointmentType;
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;

  @override
  Widget build(BuildContext context) {
    return Consumer<Appointments>(builder: (context, repo, child) => AlertDialog(
      title: Text("New Appointment"),
      content: ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: form()),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("Cancel")),
        TextButton(onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            var time = DateTime(
              _appointmentDate!.year,
              _appointmentDate!.month,
              _appointmentDate!.day,
              _appointmentTime!.hour,
              _appointmentTime!.minute);
            await repo.add(widget.clientID, time, Duration(hours: 1), _appointmentType!);
            Navigator.of(context).pop();
          }
        }, child: Text("Submit")),
      ],
    ));
  }

  Widget form() {
    return Consumer<Appointments>(builder: (context, repo, child) => FutureBuilder<Appointment>(
      future: repo.streamAll((a) => a.clientId == widget.clientID).first.then((as) {
        as.sort((a, b) => a.type.index.compareTo(b.type.index));
        return as.last;
      }),
      builder: (context, snapshot) {
        Appointment? appointment = snapshot.data;
        AppointmentType previousType = appointment?.type ?? AppointmentType.INFO;
        DateTime previousAppointmentTime = appointment?.time ?? DateTime.now();
        return Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<AppointmentType>(
              decoration: InputDecoration(
                labelText: "Appointment Type *",
              ),
              validator: _valueMustNotBeNull,
              items: AppointmentType.values
                  .where((t) => t.index > previousType.index)
                  .map((t) => DropdownMenuItem<AppointmentType>(
                child: Text(t.name()),
                value: t,
              )).toList(),
              onChanged: (value) => setState(() {
                _appointmentType = value;
              }),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Appointment Date *",
              ),
              validator: _valueMustNotBeEmpty,
              controller: _appointmentDateController,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: previousAppointmentTime.add(Duration(days: 1)),
                  firstDate: previousAppointmentTime.add(Duration(days: 1)),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _appointmentDate = picked;
                    _appointmentDateController.text = picked.toIso8601String();
                  });
                }
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Appointment Time *",
              ),
              validator: _valueMustNotBeEmpty,
              controller: _appointmentTimeController,
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    _appointmentTime = picked;
                    _appointmentTimeController.text = picked.format(context);
                  });
                }
              },
            ),
          ],),
        );
      },
    ));
  }

  String? _valueMustNotBeNull(Object? value) {
    if (value != null) {
      return null;
    }
    return "Value required";
  }

  String? _valueMustNotBeEmpty(String? value) {
    if (value?.isNotEmpty ?? false) {
      return null;
    }
    return "Value required";
  }
}
