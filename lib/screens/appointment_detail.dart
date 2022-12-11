import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:provider/provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String? appointmentId;
  final Appointment? appointment;

  const AppointmentDetailScreen({Key? key, @PathParam() this.appointmentId, this.appointment}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppointmentDetailState();

}

class AppointmentDetailState extends State<AppointmentDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _clientId;
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  AppointmentType? _appointmentType;

  @override
  void initState() {
    void update(Appointment? appointment) {
      setState(() {
        _clientId = appointment?.clientId;
        _appointmentDate = appointment?.time;
        _appointmentType = appointment?.type;
        if (appointment?.time != null) {
          _appointmentDate = DateUtils.dateOnly(appointment!.time);
          _appointmentTime = TimeOfDay.fromDateTime(appointment.time);
        }
      });
    }
    if (widget.appointment != null) {
      update(widget.appointment);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (widget.appointmentId != null) {
          update(await Provider.of<Appointments>(context, listen: false)
              .getSingle(widget.appointmentId!));
        }
      });
    }

    super.initState();
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
            Text(widget.appointmentId == null ? 'New Appointment' : 'Appointment Info'),
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
              builder: (context, clientModel, child) {
                return _showErrorOrDisplay(
                  state,
                  FutureBuilder<List<Client>>(
                    future: clientModel.getAll(),
                    builder: (context, snapshot) {
                      var clients = snapshot.data ?? [];
                      if (clients.isEmpty) {
                        return Container();
                      }
                      return DropdownButton<String>(
                        hint: Text('Please make a selection'),
                        items: clients.map((client) {
                          return DropdownMenuItem<String>(
                            value: client.id,
                            child: new Text(client.fullName()),
                          );
                        }).toList(),
                        onChanged: (selection) {
                          state.didChange(selection);
                          setState(() {
                            _clientId = selection;
                          });
                        },
                        value: _clientId,
                      );
                    },
                  ),
                );
              }),
            ));
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
