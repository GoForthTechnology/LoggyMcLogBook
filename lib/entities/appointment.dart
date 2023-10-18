
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/entities/invoice.dart';

import '../persistence/local/Indexable.dart';

part 'appointment.g.dart';

enum AppointmentStatus {
  upcoming,
  billable,
  billed;

  Color get color {
    switch (this) {
      case AppointmentStatus.upcoming:
        return Colors.green;
      case AppointmentStatus.billable:
        return Colors.red;
      case AppointmentStatus.billed:
        return Colors.grey;
    }
  }
}

@JsonSerializable(explicitToJson: true)
class Appointment extends Indexable<Appointment> {
  late String? id;
  final AppointmentType type;
  final DateTime time;
  final Duration duration;
  final String clientId;
  final int price;
  final String? invoiceId;
  Appointment(
      this.id,
      this.type,
      this.time,
      this.duration,
      this.clientId,
      this.price,
      this.invoiceId,
      );

  Appointment copyWith({
    String? id,
    AppointmentType? type,
    DateTime? time,
    Duration? duration,
    String? clientID,
    int? price,
    String? invoiceID,
  }) {
    return Appointment(
      id ?? this.id,
      type ?? this.type,
      time ?? this.time,
      duration ?? this.duration,
      clientID ?? this.clientId,
      price ?? this.price,
      invoiceID ?? this.invoiceId,
    );
  }

  AppointmentStatus status() {
    if (time.isAfter(DateTime.now())) {
      return AppointmentStatus.upcoming;
    }
    if (invoiceId != null) {
      return AppointmentStatus.billed;
    }
    return AppointmentStatus.billable;
  }

  DateTime endTime() {
    return time.add(duration);
  }

  @override
  String toString() {
    return "${type.name()} on ${timeStr()}";
  }

  String timeStr() {
    return DateFormat("d MMM @ HH:mm").format(time);
  }

  Appointment bill(Invoice? invoice) {
    return Appointment(this.id, this.type, this.time, this.duration, this.clientId, this.price, invoice?.id);
  }

  @override
  String? getId() {
    return id;
  }

  @override
  Appointment setId(String id) {
    return new Appointment(id, type, time, duration, clientId, price, invoiceId);
  }

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

enum AppointmentType {
  GENERIC,
  INFO,
  INTRO,
  FUP1,
  FUP2,
  FUP3,
  FUP4,
  FUP5,
  FUP6,
  FUP7,
  FUP8,
  FUP9,
  FUP10,
  FUP11,
  FUP12,
  PREG_EVAL
}

extension AppointmentTypeExt on AppointmentType {
  AppointmentType? next() {
    switch(this) {
      case AppointmentType.INTRO:
        return AppointmentType.FUP1;
      case AppointmentType.FUP1:
        return AppointmentType.FUP2;
      case AppointmentType.FUP2:
        return AppointmentType.FUP3;
      case AppointmentType.FUP3:
        return AppointmentType.FUP4;
      case AppointmentType.FUP4:
        return AppointmentType.FUP5;
      case AppointmentType.FUP5:
        return AppointmentType.FUP6;
      case AppointmentType.FUP6:
        return AppointmentType.FUP7;
      case AppointmentType.FUP7:
        return AppointmentType.FUP8;
      case AppointmentType.FUP8:
        return AppointmentType.FUP9;
      case AppointmentType.FUP9:
        return AppointmentType.FUP10;
      case AppointmentType.FUP10:
        return AppointmentType.FUP11;
      case AppointmentType.FUP11:
        return AppointmentType.FUP12;
      default:
        return null;
    }
  }

  String name() {
    return toString().split(".")[1];
  }
}
