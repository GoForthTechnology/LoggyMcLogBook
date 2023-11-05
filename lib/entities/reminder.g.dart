// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => Reminder(
      title: json['title'] as String,
      type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
      clientID: json['clientID'] as String?,
      triggerTime: DateTime.parse(json['triggerTime'] as String),
      appointmentID: json['appointmentID'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
      'title': instance.title,
      'type': _$ReminderTypeEnumMap[instance.type]!,
      'triggerTime': instance.triggerTime.toIso8601String(),
      'appointmentID': instance.appointmentID,
      'clientID': instance.clientID,
      'note': instance.note,
    };

const _$ReminderTypeEnumMap = {
  ReminderType.SCHEDULE_APPOINTMENT: 'SCHEDULE_APPOINTMENT',
};
