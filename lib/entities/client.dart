import 'package:floor/floor.dart';

@entity
class Client {
  @primaryKey
  final int? num;
  final String firstName;
  final String lastName;
  Client(
      this.num,
      this.firstName,
      this.lastName,
      );

  String fullName() {
    return "$firstName $lastName";
  }

  int? displayNum() {
    return (num == null) ? null : num! + 010000;
  }
}
