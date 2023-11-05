
import 'package:flutter/material.dart';
import 'package:lmlb/entities/reminder.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class Reminders extends ChangeNotifier {

  final StreamingCrudInterface<Reminder> _persistence;

  Reminders(this._persistence);

  Stream<List<Reminder>> forAppointment(String appointmentID) async* {
    yield* _persistence.getAll().map((reminders) => reminders.where((r) => r.appointmentID == appointmentID).toList());
  }

  Future<void> addReminder({
    required DateTime triggerTime,
    required String title,
    String? notes,
    String? appointmentID,
    String? clientID,
  }) async {
    await _persistence.insert(Reminder(
      title: title,
      note: notes,
      triggerTime: triggerTime,
      appointmentID: appointmentID,
      clientID: clientID,
    ));
  }
}