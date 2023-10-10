// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_general_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientGeneralInfo _$ClientGeneralInfoFromJson(Map<String, dynamic> json) =>
    ClientGeneralInfo(
      spouseFirstName: json['spouseFirstName'] as String?,
      spouseLastName: json['spouseLastName'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zip: json['zip'] as int?,
      country: json['country'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      spouseDateOfBirth: json['spouseDateOfBirth'] == null
          ? null
          : DateTime.parse(json['spouseDateOfBirth'] as String),
      email: json['email'] as String?,
      phoneDay: json['phoneDay'] as String?,
      phoneEvening: json['phoneEvening'] as String?,
      referralSource:
          $enumDecodeNullable(_$ReferralSourceEnumMap, json['referralSource']),
      referralNotes: json['referralNotes'] as String?,
    );

Map<String, dynamic> _$ClientGeneralInfoToJson(ClientGeneralInfo instance) =>
    <String, dynamic>{
      'spouseFirstName': instance.spouseFirstName,
      'spouseLastName': instance.spouseLastName,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'zip': instance.zip,
      'country': instance.country,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'spouseDateOfBirth': instance.spouseDateOfBirth?.toIso8601String(),
      'email': instance.email,
      'phoneDay': instance.phoneDay,
      'phoneEvening': instance.phoneEvening,
      'referralSource': _$ReferralSourceEnumMap[instance.referralSource],
      'referralNotes': instance.referralNotes,
    };

const _$ReferralSourceEnumMap = {
  ReferralSource.SELF: 'SELF',
  ReferralSource.FRIEND: 'FRIEND',
  ReferralSource.RELATIVE: 'RELATIVE',
  ReferralSource.PRIEST: 'PRIEST',
  ReferralSource.MINISTER: 'MINISTER',
  ReferralSource.RELIGIOUS: 'RELIGIOUS',
  ReferralSource.PHYSICIAN: 'PHYSICIAN',
  ReferralSource.NURSE: 'NURSE',
  ReferralSource.OTHER_HEALTH_PROFESSIONAL: 'OTHER_HEALTH_PROFESSIONAL',
  ReferralSource.HOSPITAL: 'HOSPITAL',
  ReferralSource.FAMILY_PLANNING_CLINIC: 'FAMILY_PLANNING_CLINIC',
  ReferralSource.CRMS_TEACHER: 'CRMS_TEACHER',
  ReferralSource.NON_CRMS_TEACHER: 'NON_CRMS_TEACHER',
  ReferralSource.SCHOOL_PERSONNEL: 'SCHOOL_PERSONNEL',
  ReferralSource.MEDIA_ADVERTISING: 'MEDIA_ADVERTISING',
  ReferralSource.OTHER: 'OTHER',
  ReferralSource.NFPMC: 'NFPMC',
};
