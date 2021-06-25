import 'dart:async';
import 'package:floor/floor.dart';
import 'package:lmlb/database/converters/appointment_type_converter.dart';
import 'package:lmlb/database/converters/currency_converter.dart';
import 'package:lmlb/database/converters/datetime_nullable_converter.dart';
import 'package:lmlb/database/converters/duration_converter.dart';
import 'package:lmlb/database/daos/client_dao.dart';
import 'package:lmlb/database/daos/invoice_dao.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'converters/datetime_converter.dart';
import 'daos/appointment_dao.dart';

part 'database.g.dart'; // the generated code will be there

@TypeConverters([
  AppointmentTypeConverter,
  CurrencyConverter,
  DateTimeConverter,
  DateTimeNullableConverter,
  DurationConverter
])
@Database(version: 3, entities: [Appointment, Client, Invoice])
abstract class AppDatabase extends FloorDatabase {
  AppointmentDao get appointmentDao;

  ClientDao get clientDao;

  InvoiceDao get invoiceDao;
}

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute(
      'CREATE TABLE IF NOT EXISTS `Appointment` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `type` INTEGER NOT NULL, `time` INTEGER NOT NULL, `duration` INTEGER NOT NULL, `clientId` INTEGER NOT NULL)');
});

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute(
      'CREATE TABLE IF NOT EXISTS `Invoice` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `clientId` INTEGER NOT NULL, `currency` INTEGER NOT NULL, `dateCreated` INTEGER NOT NULL, `dateBilled` INTEGER, `datePaid` INTEGER, FOREIGN KEY (`clientId`) REFERENCES `Client` (`num`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
});

final migrations = [migration1to2, migration2to3];
