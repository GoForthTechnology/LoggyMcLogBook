// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      practitionerID: json['practitionerID'] as String,
      num: json['num'] as int?,
      active: json['active'] as bool?,
    );

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
      'num': instance.num,
      'active': instance.active,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'practitionerID': instance.practitionerID,
    };
