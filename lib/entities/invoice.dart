import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/persistence/local/Indexable.dart';
import 'package:sprintf/sprintf.dart';

import 'currency.dart';

part 'invoice.g.dart';

@JsonSerializable(explicitToJson: true)
class AppointmentEntry {
  final String appointmentID;
  final AppointmentType appointmentType;
  final DateTime appointmentDate;
  final int price;

  AppointmentEntry(
      {required this.appointmentID,
      required this.appointmentType,
      required this.appointmentDate,
      required this.price});

  factory AppointmentEntry.fromJson(Map<String, dynamic> json) =>
      _$AppointmentEntryFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MaterialOrderSummary {
  final String orderID;
  final List<MaterialEntry> entries;
  final double shippingPrice;

  MaterialOrderSummary(
      {required this.orderID,
      required this.entries,
      required this.shippingPrice});

  static MaterialOrderSummary from(ClientOrder o) {
    return MaterialOrderSummary(
      orderID: o.id!,
      entries: o.entries
          .map((e) => MaterialEntry(
                materialName: e.displayName,
                materialID: e.materialID,
                price: e.pricePerItem,
                quantity: e.quantity,
              ))
          .toList(),
      shippingPrice: o.shippingPrice,
    );
  }

  factory MaterialOrderSummary.fromJson(Map<String, dynamic> json) =>
      _$MaterialOrderSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$MaterialOrderSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MaterialEntry {
  final String materialName;
  final String materialID;
  final int price;
  final int quantity;

  MaterialEntry(
      {required this.materialName,
      required this.materialID,
      required this.price,
      required this.quantity});

  factory MaterialEntry.fromJson(Map<String, dynamic> json) =>
      _$MaterialEntryFromJson(json);
  Map<String, dynamic> toJson() => _$MaterialEntryToJson(this);
}

enum InvoiceState { pending, billed, paid, overdue }

@JsonSerializable(explicitToJson: true)
class Invoice extends Indexable<Invoice> {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String? id;
  final int? num;
  final String clientID;
  final Currency currency;
  final DateTime dateCreated;
  DateTime? dateBilled;
  DateTime? datePaid;
  final List<AppointmentEntry> appointmentEntries;
  final List<MaterialOrderSummary> materialOrderSummaries;

  Invoice(
      {this.id,
      this.num,
      required this.clientID,
      required this.currency,
      required this.dateCreated,
      required this.appointmentEntries,
      required this.materialOrderSummaries,
      this.dateBilled,
      this.datePaid});

  InvoiceState get state {
    if (datePaid != null) {
      return InvoiceState.paid;
    }
    if (dateBilled != null) {
      if (DateTime.now().difference(dateBilled!).inDays > 30) {
        return InvoiceState.overdue;
      }
      return InvoiceState.billed;
    }
    return InvoiceState.pending;
  }

  Invoice copyWith({
    DateTime? dateBilled,
    DateTime? datePaid,
    List<AppointmentEntry>? appointmentEntries,
    List<MaterialOrderSummary>? materialOrderSummaries,
  }) {
    return Invoice(
        id: this.id,
        num: this.num,
        clientID: this.clientID,
        currency: this.currency,
        dateCreated: this.dateCreated,
        appointmentEntries: appointmentEntries ?? this.appointmentEntries,
        materialOrderSummaries:
            materialOrderSummaries ?? this.materialOrderSummaries,
        dateBilled: dateBilled ?? this.dateBilled,
        datePaid: datePaid ?? this.datePaid);
  }

  Invoice clearDateBilled() {
    return Invoice(
        id: id,
        num: num,
        clientID: clientID,
        currency: currency,
        dateCreated: dateCreated,
        appointmentEntries: appointmentEntries,
        materialOrderSummaries: materialOrderSummaries,
        dateBilled: null,
        datePaid: datePaid);
  }

  Invoice clearDatePaid() {
    return Invoice(
        id: id,
        num: num,
        clientID: clientID,
        currency: currency,
        dateCreated: dateCreated,
        appointmentEntries: appointmentEntries,
        materialOrderSummaries: materialOrderSummaries,
        dateBilled: dateBilled,
        datePaid: null);
  }

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

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}
