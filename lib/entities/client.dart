import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

part 'client.g.dart';

@JsonSerializable(explicitToJson: true)
class Client extends Indexable<Client> {
  final String? id;
  final int? num;
  final String firstName;
  final String lastName;
  Client(
      this.id,
      this.num,
      this.firstName,
      this.lastName,
      );

  @override
  String? getId() {
    return id;
  }

  @override
  Client setId(String id) {
    return new Client(id, num, firstName, lastName);
  }

  String fullName() {
    return "$firstName $lastName";
  }

  int? displayNum() {
    // TODO: fix
    return 0;
  }

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);
}
