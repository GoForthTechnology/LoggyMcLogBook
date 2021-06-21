import 'package:flutter/material.dart';
import 'package:lmlb/models/appointments.dart';

class AppointmentInfoScreenArguments {
  final Appointment? appointment;

  AppointmentInfoScreenArguments(this.appointment);
}

class AppointmentInfoScreen extends StatelessWidget {
  static const routeName = '/appointment';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as AppointmentInfoScreenArguments;
    return AppointmentInfoForm(args.appointment);
  }
}

class AppointmentInfoForm extends StatefulWidget {
  final Appointment? _appointment;

  AppointmentInfoForm(this._appointment);

  @override
  State<StatefulWidget> createState() {
    return AppointmentInfoFormState(_appointment);
  }
}

class AppointmentInfoFormState extends State<AppointmentInfoForm> {
  final Appointment? _appointment;

  AppointmentInfoFormState(this._appointment);

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appointment == null ? 'New Client' : 'Client Info'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(primary: Colors.white),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _onSave,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(true);
    }
  }

}
