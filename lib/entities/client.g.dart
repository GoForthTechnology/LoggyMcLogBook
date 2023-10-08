// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
      json['id'] as String?,
      json['num'] as int?,
      json['firstName'] as String,
      json['lastName'] as String,
      json['spouseName'] as String,
      $enumDecodeNullable(_$CurrencyEnumMap, json['currency']),
      json['active'] as bool?,
    );

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
      'id': instance.id,
      'num': instance.num,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'spouseName': instance.spouseName,
      'currency': _$CurrencyEnumMap[instance.currency],
      'active': instance.active,
    };

const _$CurrencyEnumMap = {
  Currency.USD: 'USD',
  Currency.CHF: 'CHF',
  Currency.EUR: 'EUR',
  Currency.GBP: 'GBP',
};
