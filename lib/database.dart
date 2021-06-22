import 'dart:async';
import 'package:floor/floor.dart';
import 'package:lmlb/daos/client_dao.dart';
import 'package:lmlb/entities/client.dart';
import 'package:sqflite/sqflite.dart' as sqflite;


part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Client])
abstract class AppDatabase extends FloorDatabase {
  ClientDao get personDao;
}