import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:provider/provider.dart';

class AppointmentInfoScreen extends StatelessWidget {
  final Appointment? appointment;

  const AppointmentInfoScreen({Key? key, this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppointmentInfoForm(appointment);
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
  String? _clientId;
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var clients = await Provider.of<Clients>(context, listen: false).getAll();
      if (clients.isEmpty) {
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
            style: TextButton.styleFrom(foregroundColor: Colors.white),
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
              return null;
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
              return null;
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
              return null;
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
              return null;
            },
            builder: (state) => Consumer<Clients>(
              builder: (context, clientModel, child) => _showErrorOrDisplay(
                state,
                FutureBuilder<List<Client>>(
                  future: clientModel.getAll(),
                  builder: (context, snapshot) {
                    var clients = snapshot.data ?? [];
                    return DropdownButton<Client>(
                      hint: Text('Please make a selection'),
                      items: clients.map((client) {
                        return DropdownMenuItem<Client>(
                          value: client,
                          child: new Text(client.fullName()),
                        );
                      }).toList(),
                      onChanged: (selection) {
                        state.didChange(selection);
                        setState(() {
                          _clientId = selection!.id;
                        });
                      },
                      value: clients.firstWhere((client) => client.id == _clientId, orElse: null),
                    );
                  },
                ),
              ),
            )));
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
