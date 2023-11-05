// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => Reminder(
      title: json['title'] as String,
      clientID: json['clientID'] as String?,
      triggerTime: DateTime.parse(json['triggerTime'] as String),
      appointmentID: json['appointmentID'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
      'title': instance.title,
      'triggerTime': instance.triggerTime.toIso8601String(),
      'appointmentID': instance.appointmentID,
      'clientID': instance.clientID,
      'note': instance.note,
    };
