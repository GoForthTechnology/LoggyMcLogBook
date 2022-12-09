import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

part 'client.g.dart';

@JsonSerializable(explicitToJson: true)
class Client extends Indexable<Client> {
  final String? id;
  final int? num;
  final String firstName;
  final String lastName;
  final bool? active;
  Client(
      this.id,
      this.num,
      this.firstName,
      this.lastName,
      this.active,
      );

  @override
  String? getId() {
    return id;
  }

  @override
  Client setId(String id) {
    return new Client(id, num, firstName, lastName, active);
  }

  Client assignNum(int num) {
    return new Client(id, num, firstName, lastName, active);
  }

  Client setActive(bool value) {
    return new Client(id, num, firstName, lastName, value);
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
