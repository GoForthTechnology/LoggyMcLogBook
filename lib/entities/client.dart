import 'package:lmlb/persistence/local/Indexable.dart';

class Client extends Indexable<Client> {
  final String? id;
  final String firstName;
  final String lastName;
  Client(
      this.id,
      this.firstName,
      this.lastName,
      );

  @override
  String? getId() {
    return id;
  }

  @override
  Client setId(String id) {
    return new Client(id, firstName, lastName);
  }

  String fullName() {
    return "$firstName $lastName";
  }

  int? displayNum() {
    // TODO: fix
    return 0;
  }
}
