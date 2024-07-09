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
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  final AppointmentType type;
  final DateTime time;
  final Duration duration;
  final String clientId;
  final String? invoiceId;

  Appointment({
    required this.type,
    required this.time,
    required this.duration,
    required this.clientId,
    this.id,
    this.invoiceId,
  });

  Appointment copyWith({
    String? id,
    AppointmentType? type,
    DateTime? time,
    Duration? duration,
    String? clientID,
    String? invoiceID,
  }) {
    return Appointment(
      id: id ?? this.id,
      type: type ?? this.type,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      clientId: clientID ?? this.clientId,
      invoiceId: invoiceID ?? this.invoiceId,
    );
  }

  Appointment clearInvoice() {
    return Appointment(
      id: id,
      type: type,
      time: time,
      duration: duration,
      clientId: clientId,
      invoiceId: null,
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
    return copyWith(invoiceID: invoice?.id);
  }

  @override
  String? getId() {
    return id;
  }

  @override
  Appointment setId(String id) {
    return copyWith(id: id);
  }

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
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
  int? followUpNum() {
    switch (this) {
      case AppointmentType.GENERIC:
      case AppointmentType.INFO:
      case AppointmentType.INTRO:
      case AppointmentType.PREG_EVAL:
        return null;
      case AppointmentType.FUP1:
        return 1;
      case AppointmentType.FUP2:
        return 2;
      case AppointmentType.FUP3:
        return 3;
      case AppointmentType.FUP4:
        return 4;
      case AppointmentType.FUP5:
        return 5;
      case AppointmentType.FUP6:
        return 6;
      case AppointmentType.FUP7:
        return 7;
      case AppointmentType.FUP8:
        return 8;
      case AppointmentType.FUP9:
        return 9;
      case AppointmentType.FUP10:
        return 10;
      case AppointmentType.FUP11:
        return 11;
      case AppointmentType.FUP12:
        return 11;
    }
  }

  AppointmentType? next() {
    switch (this) {
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
