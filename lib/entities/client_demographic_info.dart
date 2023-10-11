class ClientDemographicInfo {
  final Ethnicity? ethnicityWoman;
  final Ethnicity? ethnicityMan;
  final Religion? religionWoman;
  final Religion? religionMan;
  final MaritalStatus? maritalStatusWoman;
  final MaritalStatus? maritalStatusMan;

  ClientDemographicInfo({
    this.ethnicityWoman,
    this.ethnicityMan,
    this.religionWoman,
    this.religionMan,
    this.maritalStatusWoman,
    this.maritalStatusMan,
  });
}

enum Ethnicity {
  CAUCASIAN,
  AFRICAN_AMERICAN,
  HISPANIC,
  NATIVE_AMERICAN,
  ASIAN_AMERICAN,
  OTHER
}

extension EthnicityX on Ethnicity {
  int get code  => this.index + 1;
}

enum Religion {
  CATHOLIC,
  PROTESTANT,
  JEWISH,
  ATHEIST,
  AGNOSTIC,
  OTHER,
  NONE,
  ISLAMIC,
}

extension ReligionX on Religion {
  int get code  => this.index + 1;
}

enum MaritalStatus {
  SINGLE,
  ENGAGED,
  MARRIED,
  DIVORCED,
  WIDOWED,
  SEPARATED
}

extension MaritalStatusX on MaritalStatus {
  int get code  => this.index + 1;
}

