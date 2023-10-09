// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      id: json['id'] as String?,
      num: json['num'] as int?,
      spouseName: json['spouseName'] as String?,
      currency: $enumDecodeNullable(_$CurrencyEnumMap, json['currency']),
      active: json['active'] as bool?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zip: json['zip'] as String?,
      country: json['country'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      referralNotes: json['referralNotes'] as String?,
    );

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'id': instance.id,
      'num': instance.num,
      'spouseName': instance.spouseName,
      'currency': _$CurrencyEnumMap[instance.currency],
      'active': instance.active,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'zip': instance.zip,
      'country': instance.country,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'referralNotes': instance.referralNotes,
    };

const _$CurrencyEnumMap = {
  Currency.USD: 'USD',
  Currency.CHF: 'CHF',
  Currency.EUR: 'EUR',
  Currency.GBP: 'GBP',
};
