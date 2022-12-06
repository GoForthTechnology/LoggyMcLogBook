
import 'package:lmlb/persistence/local/Indexable.dart';
import 'package:sprintf/sprintf.dart';


class Invoice extends Indexable<Invoice> {
  late String? id;
  final String clientId;
  final Currency currency;
  final DateTime dateCreated;
  DateTime? dateBilled;
  DateTime? datePaid;

  Invoice(this.id, this.clientId, this.currency, this.dateCreated);

  int invoiceNum() {
    // TODO: do this properly;
    return 1001;
  }

  String invoiceNumStr() {
    return sprintf("%06d", [invoiceNum()]);
  }

  @override
  String? getId() {
    return id;
  }

  @override
  Invoice setId(String id) {
    this.id = id;
    return this;
  }
}

enum Currency {
  USD,
  CHF,
  EUR,
  GBP
}