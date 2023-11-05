
import 'package:flutter/material.dart';
import 'package:lmlb/entities/reminder.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class Reminders extends ChangeNotifier {

  final StreamingCrudInterface<Reminder> _persistence;

  Reminders(this._persistence);

  Stream<List<Reminder>> forAppointment(String appointmentID) async* {
    yield* _persistence.getWhere("appointmentID", isEqualTo: appointmentID);
  }

  Stream<List<Reminder>> forClient(String clientID) async* {
    yield* _persistence.getWhere("clientID", isEqualTo: clientID);
  }

  Future<void> addReminder({
    required DateTime triggerTime,
    required String title,
    required ReminderType type,
    String? notes,
    String? appointmentID,
    String? clientID,
  }) async {
    await _persistence.insert(Reminder(
      title: title,
      type: type,
      note: notes,
      triggerTime: triggerTime,
      appointmentID: appointmentID,
      clientID: clientID,
    ));
  }
}