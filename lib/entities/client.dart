import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

import 'currency.dart';

part 'client.g.dart';

enum ClientStatus { Prospective, Active, Inactive }

@JsonSerializable(explicitToJson: true)
class Client extends Indexable<Client> {
  final String? id;
  final int? num;
  final bool? active;
  final String firstName;
  final String lastName;

  Client({
    required this.firstName,
    required this.lastName,
    this.id,
    this.num,
    this.active,
  });

  Client copyWith({
    String? id,
    int? num,
    bool? active,
    String? firstName,
    String? lastName,
  }) {
    return Client(
      id: id ?? this.id,
      num: num ?? this.num,
      active: active ?? this.active,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  @override
  String toString() {
    return fullName();
  }

  @override
  String? getId() {
    return id;
  }

  ClientStatus status() {
    if (num == null) {
      return ClientStatus.Prospective;
    }
    if (active ?? false) {
      return ClientStatus.Active;
    }
    return ClientStatus.Inactive;
  }

  bool isActive() {
    return status() == ClientStatus.Active;
  }

  @override
  Client setId(String id) {
    return copyWith(id: id);
  }

  String fullName() {
    return "$firstName $lastName";
  }

  String? displayNum() {
    return num == null ? null : "0${num! + 10000}";
  }

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  Map<String, dynamic> toJson() => _$ClientToJson(this);
}

class DemographicInformation {

}

class PregnancyHistory {

}

class MedicalHistory {

}

class FamilyPlanningHistory {

}

class IntentionsAndExpectations {

}

class BillingInformation {
  final Currency? currency;

  BillingInformation({this.currency});
}