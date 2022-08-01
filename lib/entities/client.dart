import 'package:lmlb/persistence/local/Indexable.dart';

class Client extends Indexable<Client> {
  final int? num;
  final String firstName;
  final String lastName;
  Client(
      this.num,
      this.firstName,
      this.lastName,
      );

  int? getId() {
    return num;
  }

  Client setId(int id) {
    return new Client(id, firstName, lastName);
  }

  String fullName() {
    return "$firstName $lastName";
  }

  int? displayNum() {
    return (num == null) ? null : num! + 010000;
  }
}
