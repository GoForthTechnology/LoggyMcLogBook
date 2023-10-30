
import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/entities/client_demographic_info.dart';

part 'client_general_info.g.dart';

enum InputType {
  TEXT,
  DATE_PICKER,
  TIME_PICKER
}

abstract class GifItem extends Enum {
  InputType get inputType;
  String get label;
  List<Enum>? get optionsEnum;
}

enum GeneralInfoItem implements GifItem {
  NAME_WOMAN(
    label: "Woman's Name",
  ),
  NAME_MAN(
    label: "Man's Name",
  ),
  ADDRESS(
    label: "Address",
  ),
  CITY(
    label: "City",
  ),
  STATE(
    label: "State",
  ),
  ZIP(
    label: "Zip",
  ),
  COUNTRY(
    label: "Country",
  ),
  DOB_WOMAN(
    label: "Woman's Date of Birth",
    inputType: InputType.DATE_PICKER,
  ),
  DOB_MAN(
    label: "Man's Date of Birth",
    inputType: InputType.DATE_PICKER,
  ),
  EMAIL(
    label: "E-Mail",
  ),
  PHONE(
    label: "Phone #",
  ),
  REFERRAL_SOURCE(
    label: "Referral Source",
    optionsEnum: ReferralSource.values,
  )
  ;

  final String label;
  final List<Enum>? optionsEnum;
  final InputType inputType;

  const GeneralInfoItem({required this.label, this.optionsEnum, this.inputType = InputType.TEXT});
}

enum DemographicInfoItem implements GifItem {
  AGE_WOMAN(
    label: "Woman's Age",
  ),
  AGE_MAN(
    label: "Man's Age",
  ),
  ETHNIC_BACKGROUND_WOMAN(
    label: "Woman's Ethnic Background",
    optionsEnum: Ethnicity.values,
  ),
  ETHNIC_BACKGROUND_MAN(
    label: "Man's Ethnic Background",
    optionsEnum: Ethnicity.values,
  ),
  RELIGION_WOMAN(
    label: "Woman's Religion",
    optionsEnum: Religion.values,
  ),
  RELIGION_MAN(
    label: "Man's Religion",
    optionsEnum: Religion.values,
  ),
  MARITAL_STATUS_WOMAN(
    label: "Woman's Marital Status",
    optionsEnum: MaritalStatus.values,
  ),
  MARITAL_STATUS_MAN(
    label: "Man's Marital Status",
    optionsEnum: MaritalStatus.values,
  ),
  COMPLETED_EDUCATION_WOMAN(
    label: "Woman's Completed Education",
    optionsEnum: CompletedEducation.values,
  ),
  COMPLETED_EDUCATION_MAN(
    label: "Man's Completed Education",
    optionsEnum: CompletedEducation.values,
  ),
  OCCUPATIONAL_STATUS_WOMAN(
    label: "Woman's Occupational Status",
    optionsEnum: OccupationalStatus.values,
  ),
  OCCUPATIONAL_STATUS_MAN(
    label: "Man's Occupational Status",
    optionsEnum: OccupationalStatus.values,
  ),
  NOW_EMPLOYED_WOMAN(
    label: "Woman Now Employed?",
    optionsEnum: YesNo.values,
  ),
  NOW_EMPLOYED_MAN(
    label: "Man Now Employed?",
    optionsEnum: YesNo.values,
  ),
  ANNUAL_COMBINED_INCOME(
    label: "Annual Combined Income (optional)",
  ),
  NUMBER_OF_PEOPLE_LIVING_IN_HOUSEHOLD(
    label: "# of People Living in Household",
  ),
  ;

  final String label;
  final List<Enum>? optionsEnum;
  final InputType inputType = InputType.TEXT;

  const DemographicInfoItem({required this.label, this.optionsEnum});
}

enum PregnancyHistoryItem implements GifItem {
  NUMBER_OF_PREGNANCIES(
    label: "# of Pregnancies",
  ),
  NUMBER_LIVE_BIRTHS(
    label: "# Live Births",
  ),
  NUMBER_STILLBORN(
    label: "# Stillborn",
  ),
  NUMBER_SPONTANEOUS_ABORTION(
    label: "# Spontaneous Abortion",
  ),
  NUMBER_INDUCED_ABORTION(
    label: "# Induced Abortion",
  ),
  NUMBER_NOW_LIVING(
    label: "# Now Living",
  ),
  WOMANS_AGE_AT_FIRST_PREGNANCY(
    label: "Woman's Age at 1st Pregnancy",
  ),
  DELIVERY_METHOD(
    label: "Deliveries were",
    optionsEnum: DeliveryMethod.values,
  ),
  INFERTILITY(
    label: "Infertility",
    optionsEnum: YesNo.values,
  ),
  ;

  final String label;
  final List<Enum>? optionsEnum;
  final InputType inputType = InputType.TEXT;

  const PregnancyHistoryItem({required this.label, this.optionsEnum});
}

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

enum CompletedEducation {
  PRIMARY_SCHOOL,
  SOME_HIGH_SCHOOL,
  COMPLETED_HIGH_SCHOOL,
  VOCATIONAL_TECHNICAL,
  SOME_COLLEGE,
  COMPLETED_COLLEGE,
  GRADUATE_SCHOOL,
  PROFESSIONAL_SCHOOL,
}

enum OccupationalStatus {
  PROFESSIONAL,
  TECHNICAL,
  CLERICAL_SALES,
  SKILLED_LABORER,
  UNSKILLED_LABORER,
  HOMEMAKER,
  STUDENT,
  FARMER,
  OTHER,
}

enum YesNo {
  YES,
  NO,
  UNKNOWN
}

enum DeliveryMethod {
  VAGINAL,
  CESAREAN,
  BOTH
}