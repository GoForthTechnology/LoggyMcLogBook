// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      type: $enumDecode(_$AppointmentTypeEnumMap, json['type']),
      time: DateTime.parse(json['time'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      clientID: json['clientId'] as String,
      invoiceID: json['invoiceId'] as String?,
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'type': _$AppointmentTypeEnumMap[instance.type]!,
      'time': instance.time.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'clientId': instance.clientID,
      'invoiceId': instance.invoiceID,
    };

const _$AppointmentTypeEnumMap = {
  AppointmentType.generic: 'GENERIC',
  AppointmentType.info: 'INFO',
  AppointmentType.intro: 'INTRO',
  AppointmentType.fup1: 'FUP1',
  AppointmentType.fup2: 'FUP2',
  AppointmentType.fup3: 'FUP3',
  AppointmentType.fup4: 'FUP4',
  AppointmentType.fup5: 'FUP5',
  AppointmentType.fup6: 'FUP6',
  AppointmentType.fup7: 'FUP7',
  AppointmentType.fup8: 'FUP8',
  AppointmentType.fup9: 'FUP9',
  AppointmentType.fup10: 'FUP10',
  AppointmentType.fup11: 'FUP11',
  AppointmentType.fup12: 'FUP12',
  AppointmentType.pregEval: 'PREG_EVAL',
};
