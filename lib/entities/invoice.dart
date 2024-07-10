import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/entities/appointment.dart';
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

  Invoice(
      {this.id,
      this.num,
      required this.clientID,
      required this.currency,
      required this.dateCreated,
      required this.appointmentEntries,
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

  Invoice copyWith(
      {DateTime? dateBilled,
      DateTime? datePaid,
      List<AppointmentEntry>? appointmentEntries}) {
    return Invoice(
        id: this.id,
        num: this.num,
        clientID: this.clientID,
        currency: this.currency,
        dateCreated: this.dateCreated,
        appointmentEntries: appointmentEntries ?? this.appointmentEntries,
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
