import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/persistence/local/Indexable.dart';
import 'package:sprintf/sprintf.dart';

import 'currency.dart';

part 'invoice.g.dart';

enum InvoiceStatus {
  draft,
  billed,
  paid;

  Color get color {
    switch (this) {
      case InvoiceStatus.draft:
        return Colors.green;
      case InvoiceStatus.billed:
        return Colors.red;
      case InvoiceStatus.paid:
        return Colors.grey;
    }
  }
}

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

  int invoiceNum() {
    var invoiceNum = num ?? 0;
    return 100 + invoiceNum;
  }

  String invoiceNumStr() {
    return sprintf("%06d", [invoiceNum()]);
  }

  InvoiceStatus status() {
    if (datePaid != null) {
      return InvoiceStatus.paid;
    }
    if (dateBilled != null) {
      return InvoiceStatus.billed;
    }
    return InvoiceStatus.draft;
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
