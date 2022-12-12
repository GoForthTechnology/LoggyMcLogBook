// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      json['id'] as String?,
      $enumDecode(_$AppointmentTypeEnumMap, json['type']),
      DateTime.parse(json['time'] as String),
      Duration(microseconds: json['duration'] as int),
      json['clientId'] as String,
      json['price'] as int,
      json['invoiceId'] as String?,
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AppointmentTypeEnumMap[instance.type]!,
      'time': instance.time.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'clientId': instance.clientId,
      'price': instance.price,
      'invoiceId': instance.invoiceId,
    };

const _$AppointmentTypeEnumMap = {
  AppointmentType.GENERIC: 'GENERIC',
  AppointmentType.INFO: 'INFO',
  AppointmentType.INTRO: 'INTRO',
  AppointmentType.FUP1: 'FUP1',
  AppointmentType.FUP2: 'FUP2',
  AppointmentType.FUP3: 'FUP3',
  AppointmentType.FUP4: 'FUP4',
  AppointmentType.FUP5: 'FUP5',
  AppointmentType.FUP6: 'FUP6',
  AppointmentType.FUP7: 'FUP7',
  AppointmentType.FUP8: 'FUP8',
  AppointmentType.FUP9: 'FUP9',
  AppointmentType.FUP10: 'FUP10',
  AppointmentType.FUP11: 'FUP11',
  AppointmentType.FUP12: 'FUP12',
  AppointmentType.PREG_EVAL: 'PREG_EVAL',
};
