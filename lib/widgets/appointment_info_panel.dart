import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:provider/provider.dart';

class AppointmentInfoPanel extends StatelessWidget {
  final Appointment appointment;

  const AppointmentInfoPanel({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Consumer<Appointments>(builder: (context, repo, child) => ChangeNotifierProvider(
      create: (context) => AppointmentInfoModel(
        currentAppointment: appointment,
        appointmentRepo: repo,
      ),
      child: ExpandableInfoPanel(
        title: "Appointment Info",
        subtitle: "",
        initiallyExpanded: true,
        contents: [
          Row(children: [
            AppointmentDateField(),
            AppointmentTimeField(),
          ]),
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.note),
              label: Text("Notes"),
            ),
            maxLines: null,
          ),
        ],
      ),
    ));
  }

}

class AppointmentTimeField extends StatelessWidget {
  final _controller = TextEditingController();

  String formatTime(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time);
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<AppointmentInfoModel>(builder: (context, model, child) {
      _controller.text = formatTime(context, TimeOfDay.fromDateTime(model.currentAppointment.time));
      return Flexible(child: TextFormField(
        decoration: InputDecoration(
          labelText: "Appointment Date *",
          icon: Icon(Icons.event),
        ),
        controller: _controller,
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(model.currentAppointment.time),
          );
          if (picked != null) {
            await model.updateTime(picked);
            _controller.text = formatTime(context, picked);
          }
        },
      ));
    });
  }
}

class AppointmentDateField extends StatelessWidget {
  final _controller = TextEditingController();

  String formatDate(BuildContext context, DateTime time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatShortDate(time);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentInfoModel>(builder: (context, model, child) {
      _controller.text = formatDate(context, model.currentAppointment.time);
      return Flexible(child: TextFormField(
        decoration: InputDecoration(
          labelText: "Appointment Date *",
          icon: Icon(Icons.event),
        ),
        controller: _controller,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: model.initialDate(),
            firstDate: model.firstDate(),
            lastDate: model.lastDate(),
          );
          if (picked != null) {
            await model.updateDate(picked);
            _controller.text = formatDate(context, picked);
          }
        },
      ));
    });
  }
}

class AppointmentInfoModel extends ChangeNotifier {
  final Appointments _repo;

  late Appointment currentAppointment;
  late Appointment? previousAppointment;
  late Appointment? nextAppointment;

  AppointmentInfoModel({required this.currentAppointment, required Appointments appointmentRepo})
      : _repo = appointmentRepo {
    appointmentRepo.getPrevious(currentAppointment).then((a) { previousAppointment = a; notifyListeners(); });
    appointmentRepo.getNext(currentAppointment).then((a) { nextAppointment = a; notifyListeners(); });
  }

  DateTime firstDate() {
    if (previousAppointment != null) {
      return previousAppointment!.time.add(Duration(days: 1));
    }
    return DateTime.now().subtract(Duration(days: 365));
  }

  DateTime lastDate() {
    if (nextAppointment != null) {
      return nextAppointment!.time.subtract(Duration(days: 1));
    }
    return DateTime.now().add(Duration(days: 365));
  }

  DateTime initialDate() {
    return currentAppointment.time;
  }

  Future<void> updateDate(DateTime date) async {
    var newTime = DateTime(date.year, date.month, date.day, currentAppointment.time.hour, currentAppointment.time.minute);
    var newAppointment = currentAppointment.copyWith(time: newTime);
    await _repo.updateAppointment(newAppointment);

    currentAppointment = newAppointment;
    notifyListeners();
  }

  Future<void> updateTime(TimeOfDay time) async {
    var newTime = DateTime(currentAppointment.time.year, currentAppointment.time.month, currentAppointment.time.day, time.hour, time.minute);
    var newAppointment = currentAppointment.copyWith(time: newTime);
    await _repo.updateAppointment(newAppointment);

    currentAppointment = newAppointment;
    notifyListeners();
  }
}
