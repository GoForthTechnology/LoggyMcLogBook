
import 'package:sprintf/sprintf.dart';

const startingId = 100;

class Invoice {
  late int? id;
  final int clientId;
  final Currency currency;
  final DateTime dateCreated;
  DateTime? dateBilled;
  DateTime? datePaid;

  Invoice(this.id, this.clientId, this.currency, this.dateCreated);

  int invoiceNum() {
    return startingId + id!;
  }

  String invoiceNumStr() {
    return sprintf("%06d", [invoiceNum()]);
  }
}

enum Currency {
  USD,
  CHF,
  EUR,
  GBP
}