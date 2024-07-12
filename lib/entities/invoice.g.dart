// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentEntry _$AppointmentEntryFromJson(Map<String, dynamic> json) =>
    AppointmentEntry(
      appointmentID: json['appointmentID'] as String,
      appointmentType:
          $enumDecode(_$AppointmentTypeEnumMap, json['appointmentType']),
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$AppointmentEntryToJson(AppointmentEntry instance) =>
    <String, dynamic>{
      'appointmentID': instance.appointmentID,
      'appointmentType': _$AppointmentTypeEnumMap[instance.appointmentType]!,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'price': instance.price,
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

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      num: (json['num'] as num?)?.toInt(),
      clientID: json['clientID'] as String,
      currency: $enumDecode(_$CurrencyEnumMap, json['currency']),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      appointmentEntries: (json['appointmentEntries'] as List<dynamic>)
          .map((e) => AppointmentEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      dateBilled: json['dateBilled'] == null
          ? null
          : DateTime.parse(json['dateBilled'] as String),
      datePaid: json['datePaid'] == null
          ? null
          : DateTime.parse(json['datePaid'] as String),
    );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
      'num': instance.num,
      'clientID': instance.clientID,
      'currency': _$CurrencyEnumMap[instance.currency]!,
      'dateCreated': instance.dateCreated.toIso8601String(),
      'dateBilled': instance.dateBilled?.toIso8601String(),
      'datePaid': instance.datePaid?.toIso8601String(),
      'appointmentEntries':
          instance.appointmentEntries.map((e) => e.toJson()).toList(),
    };

const _$CurrencyEnumMap = {
  Currency.USD: 'USD',
  Currency.CHF: 'CHF',
  Currency.EUR: 'EUR',
  Currency.GBP: 'GBP',
};
