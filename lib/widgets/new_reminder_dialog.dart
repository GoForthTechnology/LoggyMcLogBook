
import 'package:flutter/material.dart';
import 'package:lmlb/entities/reminder.dart';
import 'package:lmlb/repos/reminders.dart';
import 'package:provider/provider.dart';

class NewReminderDialog extends StatefulWidget {
  final String defaultTitle;
  final ReminderType reminderType;
  final int defaultTriggerDaysAway;
  final String? appointmentID;
  final String? clientID;

  const NewReminderDialog({super.key, this.appointmentID, this.clientID, required this.defaultTriggerDaysAway, required this.defaultTitle, required this.reminderType});

  @override
  State<StatefulWidget> createState() => _NewReminderDialogState();
}

class _NewReminderDialogState extends State<NewReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _triggerDateController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _triggerDate;

  @override
  void initState() {
    _titleController.text = widget.defaultTitle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Reminders>(builder: (context, repo, child) => AlertDialog(
      title: Text("New Reminder"),
      content: ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: form()),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("Cancel")),
        TextButton(onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            var time = DateTime(
              _triggerDate!.year,
              _triggerDate!.month,
              _triggerDate!.day,
              0, 0);
            repo.addReminder(
              title: _titleController.text,
              type: widget.reminderType,
              triggerTime: time,
              notes: _notesController.text,
              appointmentID: widget.appointmentID,
              clientID: widget.clientID,
            ).then((_) => Navigator.of(context).pop()).onError((error, stackTrace) {
              print(error);
            });
          }
        }, child: Text("Submit")),
      ],
    ));
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          decoration: InputDecoration(label: Text("Title")),
          controller: _titleController,
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: "Reminder Date *",
          ),
          validator: _valueMustNotBeEmpty,
          controller: _triggerDateController,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(Duration(days: widget.defaultTriggerDaysAway)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                _triggerDate = picked;
                _triggerDateController.text = picked.toIso8601String();
              });
            }
          },
        ),
        TextFormField(
          decoration: InputDecoration(label: Text("Notes")),
          controller: _notesController,
          maxLines: null,
        ),
      ],),
    );
  }

  String? _valueMustNotBeEmpty(String? value) {
    if (value?.isNotEmpty ?? false) {
      return null;
    }
    return "Value required";
  }
}
