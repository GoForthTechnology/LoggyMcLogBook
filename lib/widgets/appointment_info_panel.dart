import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/widgets/info_panel.dart';

class AppointmentInfoPanel extends StatelessWidget {
  final Appointment appointment;

  const AppointmentInfoPanel({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
      title: "Appointment Info",
      subtitle: "",
      initiallyExpanded: true,
      contents: [
        Row(children: [
          Flexible(child: TextFormField(
            decoration: InputDecoration(
              labelText: "Appointment Date *",
              icon: Icon(Icons.event),
            ),
            initialValue: "",
            //controller: _appointmentDateController,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: appointment.time.add(Duration(days: 1)),
                firstDate: appointment.time.add(Duration(days: 1)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) {
                /*setState(() {
                    _appointmentDate = picked;
                    _appointmentDateController.text = picked.toIso8601String();
                  });*/
              }
            },
          )),
          Flexible(child: TextFormField(
            decoration: InputDecoration(
              labelText: "Appointment Time *",
              icon: Icon(Icons.access_time),
            ),
            //controller: _appointmentTimeController,
            initialValue: "",
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                /*setState(() {
                    _appointmentTime = picked;
                    _appointmentTimeController.text = picked.format(context);
                  });*/
              }
            },
          )),
        ],),
        TextFormField(
          decoration: InputDecoration(
            icon: Icon(Icons.note),
            label: Text("Notes"),
          ),
          maxLines: null,
        ),
      ],
    );
  }

}
