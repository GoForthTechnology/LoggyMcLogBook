import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

part 'reminder.g.dart';

enum ReminderType {
  SCHEDULE_APPOINTMENT,
  ;
}

@JsonSerializable(explicitToJson: true)
class Reminder extends Indexable<Reminder> {

  @JsonKey(includeFromJson: false, includeToJson: false) final String? id;
  final String title;
  final ReminderType type;
  final DateTime triggerTime;
  final String? appointmentID;
  final String? clientID;
  final String? note;

  Reminder({required this.title, required this.type, this.clientID, required this.triggerTime, required this.appointmentID, this.id, this.note});

  Reminder copyWith({
    String? id,
    String? title,
    ReminderType? type,
    String? note,
    DateTime? triggerTime,
    String? appointmentID,
    String? clientID,
  }) {
    return Reminder(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      note: note ?? this.note,
      triggerTime: triggerTime ?? this.triggerTime,
      appointmentID: appointmentID ?? this.appointmentID,
      clientID: clientID ?? this.clientID,
    );
  }

  @override
  String? getId() {
    return id;
  }

  @override
  Reminder setId(String id) {
    return copyWith(id: id);
  }

  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);
  Map<String, dynamic> toJson() => _$ReminderToJson(this);
}