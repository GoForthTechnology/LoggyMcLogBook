
import 'package:json_annotation/json_annotation.dart';

part 'client_general_info.g.dart';

@JsonSerializable(explicitToJson: true)
class ClientGeneralInfo {
  final String? spouseFirstName;
  final String? spouseLastName;

  final String? address;
  final String? city;
  final String? state;
  final int? zip;

  final String? country;

  final DateTime? dateOfBirth;
  final DateTime? spouseDateOfBirth;

  final String? email;
  final String? phoneDay;
  final String? phoneEvening;

  final ReferralSource? referralSource;
  final String? referralNotes;

  ClientGeneralInfo({
    this.spouseFirstName,
    this.spouseLastName,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.dateOfBirth,
    this.spouseDateOfBirth,
    this.email,
    this.phoneDay,
    this.phoneEvening,
    this.referralSource,
    this.referralNotes,
  });

  ClientGeneralInfo copyWith({
    String? spouseFirstName,
    String? spouseLastName,
    String? address,
    String? city,
    String? state,
    int? zip,
    String? country,
    DateTime? dateOfBirth,
    DateTime? spouseDateOfBirth,
    String? email,
    String? phoneDay,
    String? phoneEvening,
    ReferralSource? referralSource,
    String? referralNotes,
  }) {
    return ClientGeneralInfo(
      spouseFirstName: spouseFirstName ?? this.spouseFirstName,
      spouseLastName: spouseLastName ?? this.spouseLastName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      spouseDateOfBirth: spouseDateOfBirth ?? this.spouseDateOfBirth,
      email: email ?? this.email,
      phoneDay: phoneDay ?? this.phoneDay,
      phoneEvening: phoneEvening ?? this.phoneEvening,
      referralSource: referralSource ?? this.referralSource,
      referralNotes: referralNotes ?? this.referralNotes,
    );
  }
}

enum ReferralSource {
  SELF,
  FRIEND,
  RELATIVE,
  PRIEST,
  MINISTER,
  RELIGIOUS,
  PHYSICIAN,
  NURSE,
  OTHER_HEALTH_PROFESSIONAL,
  HOSPITAL,
  FAMILY_PLANNING_CLINIC,
  CRMS_TEACHER,
  NON_CRMS_TEACHER,
  SCHOOL_PERSONNEL,
  MEDIA_ADVERTISING,
  OTHER,
  NFPMC,
}

extension ReferralSourceX on ReferralSource {
  int get code  => this.index + 1;
}
