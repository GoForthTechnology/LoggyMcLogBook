import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:provider/provider.dart';

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
  final _formKey = GlobalKey<FormState>();

  late final Appointment? _appointment;
  int? _clientId;
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  AppointmentType? _appointmentType;

  AppointmentInfoFormState(Appointment? appointment) {
    this._appointment = appointment;
    this._clientId = _appointment?.clientId;
    this._appointmentType = _appointment?.type;
    this._appointmentDate = _appointment?.time;
    this._appointmentTime = _appointmentDate == null
        ? null
        : TimeOfDay.fromDateTime(_appointmentDate!);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (Provider.of<Clients>(context, listen: false).getAll().isEmpty) {
        Widget continueButton = TextButton(
          child: Text("Ack"),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("No Clients Found"),
          content:
              Text("Please add the client before scheduling an appointment"),
          actions: [
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
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_appointment == null ? 'New Appointment' : 'Appointment Info'),
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
            children: [
              _buildClientSelector(context),
              _buildTypeSelector(context),
              _buildEventDate(context),
              _buildEventTime(context),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final appointmentTime = DateTime(
          _appointmentDate!.year,
          _appointmentDate!.month,
          _appointmentDate!.day,
          _appointmentTime!.hour,
          _appointmentTime!.minute);
      Provider.of<Appointments>(context, listen: false)
          .add(_clientId!, appointmentTime, Duration(hours: 1),
              _appointmentType!)
          .then((_) {
        Navigator.of(context).pop(true);
      });
    } else {
      print("Validation error");
    }
  }

  Widget _buildEventDate(BuildContext context) {
    final Widget display = _appointmentDate == null
        ? Text("Select a date")
        : Text(_appointmentDate!.toIso8601String());
    return _buildContainer(
        "Appointment Date:",
        FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                return "Date required";
              }
            },
            builder: (state) => GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), // Refer step 1
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) {
                    state.didChange(picked);
                    setState(() {
                      _appointmentDate = picked;
                    });
                  }
                },
                child: _showErrorOrDisplay(state, display))));
  }

  Widget _buildEventTime(BuildContext context) {
    final Widget display = _appointmentTime == null
        ? Text("Select a time")
        : Text(_appointmentTime!.format(context));
    return _buildContainer(
        "Appointment Time:",
        FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                return "Value required";
              }
            },
            builder: (state) => GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    state.didChange(picked);
                    setState(() {
                      _appointmentTime = picked;
                    });
                  }
                },
                child: _showErrorOrDisplay(state, display))));
  }

  Widget _buildTypeSelector(BuildContext context) {
    return _buildContainer(
        "Appointment Type:",
        FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                return "Select a value";
              }
            },
            builder: (state) => _showErrorOrDisplay(
                state,
                DropdownButton<AppointmentType>(
                  hint: Text('Please make a selection'),
                  items: AppointmentType.values.map((value) {
                    return DropdownMenuItem<AppointmentType>(
                      value: value,
                      child: new Text(value.name()),
                    );
                  }).toList(),
                  onChanged: (selection) {
                    state.didChange(selection);
                    setState(() {
                      _appointmentType = selection;
                    });
                  },
                  value: _appointmentType,
                ))));
  }

  Widget _buildClientSelector(BuildContext context) {
    return _buildContainer(
        "Client:",
        FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                return "Select a value";
              }
            },
            builder: (state) => Consumer<Clients>(
                builder: (context, clientModel, child) => _showErrorOrDisplay(
                    state,
                    DropdownButton<Client>(
                      hint: Text('Please make a selection'),
                      items: clientModel.getAll().map((client) {
                        return DropdownMenuItem<Client>(
                          value: client,
                          child: new Text(client.fullName()),
                        );
                      }).toList(),
                      onChanged: (selection) {
                        state.didChange(selection);
                        setState(() {
                          _clientId = selection!.num;
                        });
                      },
                      value: _clientId == null
                          ? null
                          : clientModel.get(_clientId!),
                    )))));
  }

  Widget _showErrorOrDisplay(FormFieldState state, Widget display) {
    return Column(
      children: [
        display,
        state.hasError
            ? Text(
                state.errorText!,
                style: TextStyle(color: Colors.red),
              )
            : Container()
      ],
    );
  }

  Widget _buildContainer(String title, Widget content) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(children: [
        Container(
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          margin: EdgeInsets.only(right: 10.0),
        ),
        content,
      ]),
    );
  }
}
