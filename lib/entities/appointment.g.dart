// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      type: $enumDecode(_$AppointmentTypeEnumMap, json['type']),
      time: DateTime.parse(json['time'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      clientID: json['clientID'] as String,
      invoiceID: json['invoiceID'] as String?,
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'type': _$AppointmentTypeEnumMap[instance.type]!,
      'time': instance.time.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'clientID': instance.clientID,
      'invoiceID': instance.invoiceID,
    };

const _$AppointmentTypeEnumMap = {
  AppointmentType.generic: 'generic',
  AppointmentType.info: 'info',
  AppointmentType.intro: 'intro',
  AppointmentType.fup1: 'fup1',
  AppointmentType.fup2: 'fup2',
  AppointmentType.fup3: 'fup3',
  AppointmentType.fup4: 'fup4',
  AppointmentType.fup5: 'fup5',
  AppointmentType.fup6: 'fup6',
  AppointmentType.fup7: 'fup7',
  AppointmentType.fup8: 'fup8',
  AppointmentType.fup9: 'fup9',
  AppointmentType.fup10: 'fup10',
  AppointmentType.fup11: 'fup11',
  AppointmentType.fup12: 'fup12',
  AppointmentType.pregEval: 'pregEval',
};
