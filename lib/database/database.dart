import 'dart:async';
import 'package:floor/floor.dart';
import 'package:lmlb/database/converters/appointment_type_converter.dart';
import 'package:lmlb/database/converters/duration_converter.dart';
import 'package:lmlb/database/daos/client_dao.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'converters/datetime_converter.dart';
import 'daos/appointment_dao.dart';

part 'database.g.dart'; // the generated code will be there

@TypeConverters([AppointmentTypeConverter, DateTimeConverter, DurationConverter])
@Database(version: 2, entities: [Appointment, Client])
abstract class AppDatabase extends FloorDatabase {
  AppointmentDao get appointmentDao;
  ClientDao get clientDao;
}

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('CREATE TABLE IF NOT EXISTS `Appointment` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `type` INTEGER NOT NULL, `time` INTEGER NOT NULL, `duration` INTEGER NOT NULL, `clientId` INTEGER NOT NULL)');
});

final migrations = [migration1to2];