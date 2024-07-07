// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      num: (json['num'] as num?)?.toInt(),
      clientID: json['clientID'] as String,
      currency: $enumDecode(_$CurrencyEnumMap, json['currency']),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
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
    };

const _$CurrencyEnumMap = {
  Currency.USD: 'USD',
  Currency.CHF: 'CHF',
  Currency.EUR: 'EUR',
  Currency.GBP: 'GBP',
};
