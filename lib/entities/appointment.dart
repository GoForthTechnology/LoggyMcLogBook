
import 'package:intl/intl.dart';
import 'package:lmlb/entities/invoice.dart';

import '../persistence/local/Indexable.dart';

class Appointment extends Indexable<Appointment>{
  late String? id;
  final AppointmentType type;
  final DateTime time;
  final Duration duration;
  final String clientId;
  final String? invoiceId;
  Appointment(
      this.id,
      this.type,
      this.time,
      this.duration,
      this.clientId,
      this.invoiceId,
      );

  DateTime endTime() {
    return time.add(duration);
  }

  String timeStr() {
    return DateFormat("d MMM H:m").format(time);
  }

  Appointment bill(Invoice? invoice) {
    return Appointment(this.id, this.type, this.time, this.duration, this.clientId, invoice?.id);
  }

  @override
  String? getId() {
    return id;
  }

  @override
  Appointment setId(String id) {
    return new Appointment(id, type, time, duration, clientId, invoiceId);
  }
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

  int price(Currency currency) {
    switch(currency) {
      default:
        switch(this) {
          case AppointmentType.GENERIC:
          case AppointmentType.INFO:
          case AppointmentType.INTRO:
            return 0;
          default:
            return 75;
        }
    }
  }
}
