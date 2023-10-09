import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

import 'currency.dart';

part 'client.g.dart';

enum ClientStatus { Prospective, Active, Inactive }

@JsonSerializable(explicitToJson: true)
class Client extends Indexable<Client> {
  final String firstName;
  final String lastName;

  final String? id;
  final int? num;
  final String? spouseName;
  final Currency? currency;
  final bool? active;

  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;

  final String? email;
  final String? phoneNumber;

  final String? referralNotes;

  Client({
    required this.firstName,
    required this.lastName,
    this.id,
    this.num,
    this.spouseName,
    this.currency,
    this.active,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.email,
    this.phoneNumber,
    this.referralNotes,
  });

  Client copyWith({
    String? id,
    int? num,
    String? firstName,
    String? lastName,
    String? spouseName,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? country,
    Currency? currency,
    bool? active,
    String? email,
    String? phoneNumber,
    String? referralNotes,
  }) {
    return Client(
      id: id ?? this.id,
      num: num ?? this.num,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      spouseName: spouseName ?? this.spouseName,
      currency: currency ?? this.currency,
      active: active ?? this.active,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      referralNotes: referralNotes ?? this.referralNotes,
    );
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
