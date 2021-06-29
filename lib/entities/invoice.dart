
import 'package:floor/floor.dart';
import 'package:lmlb/entities/client.dart';
import 'package:sprintf/sprintf.dart';

const startingId = 100;

@Entity(foreignKeys: [
  ForeignKey(childColumns: ['clientId'], parentColumns: ['num'], entity: Client),
],)
class Invoice {
  @PrimaryKey(autoGenerate: true)
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