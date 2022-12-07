
import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';
import 'package:sprintf/sprintf.dart';

part 'invoice.g.dart';

@JsonSerializable(explicitToJson: true)
class Invoice extends Indexable<Invoice> {
  late String? id;
  final int? num;
  final String clientId;
  final Currency currency;
  final DateTime dateCreated;
  DateTime? dateBilled;
  DateTime? datePaid;

  Invoice(this.id, this.num, this.clientId, this.currency, this.dateCreated);

  int invoiceNum() {
    var invoiceNum = num ?? 0;
    return 100 + invoiceNum;
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

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}

enum Currency {
  USD,
  CHF,
  EUR,
  GBP
}