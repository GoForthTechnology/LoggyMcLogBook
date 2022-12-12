import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/client_selector.dart';
import 'package:lmlb/widgets/input_container.dart';
import 'package:provider/provider.dart';

class AppointmentDetailModel extends ClientSelectorModel {
  final Appointments appointmentRepo;
  final formKey = GlobalKey<FormState>();
  final Appointment? appointment;

  String? clientId;
  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;
  AppointmentType? appointmentType;
  TextEditingController priceController = new TextEditingController();

  AppointmentDetailModel(this.appointment, this.appointmentRepo) : super(appointment?.clientId) {
    clientId = appointment?.clientId;
    appointmentType = appointment?.type;
    priceController.text = appointment?.price.toString() ?? "";
    final time = appointment?.time;
    if (time != null) {
      appointmentDate = DateUtils.dateOnly(time);
      appointmentTime = TimeOfDay.fromDateTime(time);
    }
  }

  void updateClientId(String? value) {
    clientId = value;
    notifyListeners();
  }

  void updateAppointmentType(AppointmentType? value) {
    appointmentType = value;
    notifyListeners();
  }

  void updateAppointmentDate(DateTime? value) {
    appointmentDate = value;
    notifyListeners();
  }

  void updateAppointmentTime(TimeOfDay? value) {
    appointmentTime = value;
    notifyListeners();
  }

  Future<void> save() {
    final appointmentTime = DateTime(
        appointmentDate!.year,
        appointmentDate!.month,
        appointmentDate!.day,
        appointmentDate!.hour,
        appointmentDate!.minute);
    return appointmentRepo.add(
        clientId!, appointmentTime, Duration(hours: 1), appointmentType!, priceController.text as int);
  }
}

class AppointmentDetailScreen extends StatelessWidget {
  final String? appointmentId;

  const AppointmentDetailScreen({Key? key, @PathParam() this.appointmentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Appointments, Clients>(builder: (context, appointmentRepo, clientRepo, child) => FutureBuilder<Appointment?>(
      future: appointmentId == null ? Future.value(null) : appointmentRepo.getSingle(appointmentId!),
      builder: (context, snapshot) {
        var appointment = snapshot.data;
        if (appointmentId != null && appointment == null) {
          return Container();
        }
        return ChangeNotifierProvider(
          create: (context) => AppointmentDetailModel(appointment, appointmentRepo),
          child: Consumer<AppointmentDetailModel>(builder: (context, model, child) => body(context, model)),
        );
      },
    ));
  }

  Widget body(BuildContext context, AppointmentDetailModel model) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(appointmentId == null ? 'New Appointment' : 'Appointment Info'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () => _onSave(context, model),
          )
        ],
      ),
      body: Form(
        key: model.formKey,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClientSelector(context, model),
              _buildTypeSelector(context, model),
              _buildEventDate(context, model),
              _buildEventTime(context, model),
              _buildPrice(context, model),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave(BuildContext context, AppointmentDetailModel model) {
    if (model.formKey.currentState!.validate()) {
      model.save().then((_) => Navigator.of(context).pop());
    } else {
      print("Validation error");
    }
  }

  Widget _buildEventDate(BuildContext context, AppointmentDetailModel model) {
    final Widget display = model.appointmentDate == null
        ? Text("Select a date")
        : Text(model.appointmentDate!.toIso8601String());
    return InputContainer(
        title: "Appointment Date:",
        content: FormField(
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
                    model.updateAppointmentDate(picked);
                  }
                },
                child: _showErrorOrDisplay(state, display))));
  }

  Widget _buildPrice(BuildContext context, AppointmentDetailModel model) {
    var formField = Expanded(child: TextFormField(
      controller: model.priceController,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    ));
    return Consumer<Clients>(builder: (context, clients, child) => FutureBuilder<Client?>(
      future: model.clientId == null ? Future.value(null) : clients.get(model.clientId!),
      builder: (context, snapshot) {
        var currency = snapshot.data?.currency?.name ?? "TBD";
        return InputContainer(title: "Appointment Price ($currency):", content: formField);
      },
    ));
  }

  Widget _buildEventTime(BuildContext context, AppointmentDetailModel model) {
    final Widget display = model.appointmentTime == null
        ? Text("Select a time")
        : Text(model.appointmentTime!.format(context));
    return InputContainer(
        title: "Appointment Time:",
        content: FormField(
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
                    model.updateAppointmentTime(picked);
                  }
                },
                child: _showErrorOrDisplay(state, display))));
  }

  Widget _buildTypeSelector(BuildContext context, AppointmentDetailModel model) {
    return InputContainer(
        title: "Appointment Type:",
        content: FormField(
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
                    model.updateAppointmentType(selection);
                  },
                  value: model.appointmentType,
                ))));
  }

  Widget _buildClientSelector(BuildContext context, AppointmentDetailModel model) {
    return ClientSelector(
      canEdit: model.appointment == null,
      selectedClientId: model.clientId,
      onUpdate: model.updateClientId,
    );
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
}
