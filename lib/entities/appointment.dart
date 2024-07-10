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
  generic,
  info,
  intro,
  fup1,
  fup2,
  fup3,
  fup4,
  fup5,
  fup6,
  fup7,
  fup8,
  fup9,
  fup10,
  fup11,
  fup12,
  pregEval
}

extension AppointmentTypeExt on AppointmentType {
  String prettyName() {
    switch (this) {
      case AppointmentType.generic:
        return "Generic";
      case AppointmentType.info:
        return "Info Session";
      case AppointmentType.intro:
        return "Intro Session";
      case AppointmentType.pregEval:
        return "Pregnancy Evaluation";
      case AppointmentType.fup1:
      case AppointmentType.fup2:
      case AppointmentType.fup3:
      case AppointmentType.fup4:
      case AppointmentType.fup5:
      case AppointmentType.fup6:
      case AppointmentType.fup7:
      case AppointmentType.fup8:
      case AppointmentType.fup9:
      case AppointmentType.fup10:
      case AppointmentType.fup11:
      case AppointmentType.fup12:
        return "Follow Up #${followUpNum()}";
    }
  }

  int? followUpNum() {
    switch (this) {
      case AppointmentType.generic:
      case AppointmentType.info:
      case AppointmentType.intro:
      case AppointmentType.pregEval:
        return null;
      case AppointmentType.fup1:
        return 1;
      case AppointmentType.fup2:
        return 2;
      case AppointmentType.fup3:
        return 3;
      case AppointmentType.fup4:
        return 4;
      case AppointmentType.fup5:
        return 5;
      case AppointmentType.fup6:
        return 6;
      case AppointmentType.fup7:
        return 7;
      case AppointmentType.fup8:
        return 8;
      case AppointmentType.fup9:
        return 9;
      case AppointmentType.fup10:
        return 10;
      case AppointmentType.fup11:
        return 11;
      case AppointmentType.fup12:
        return 11;
    }
  }

  AppointmentType? next() {
    switch (this) {
      case AppointmentType.intro:
        return AppointmentType.fup1;
      case AppointmentType.fup1:
        return AppointmentType.fup2;
      case AppointmentType.fup2:
        return AppointmentType.fup3;
      case AppointmentType.fup3:
        return AppointmentType.fup4;
      case AppointmentType.fup4:
        return AppointmentType.fup5;
      case AppointmentType.fup5:
        return AppointmentType.fup6;
      case AppointmentType.fup6:
        return AppointmentType.fup7;
      case AppointmentType.fup7:
        return AppointmentType.fup8;
      case AppointmentType.fup8:
        return AppointmentType.fup9;
      case AppointmentType.fup9:
        return AppointmentType.fup10;
      case AppointmentType.fup10:
        return AppointmentType.fup11;
      case AppointmentType.fup11:
        return AppointmentType.fup12;
      default:
        return null;
    }
  }

  String name() {
    return toString().split(".")[1];
  }
}
