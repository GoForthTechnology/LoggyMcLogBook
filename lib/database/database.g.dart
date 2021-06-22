// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AppointmentDao? _appointmentDaoInstance;

  ClientDao? _clientDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Appointment` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `type` INTEGER NOT NULL, `time` INTEGER NOT NULL, `duration` INTEGER NOT NULL, `clientId` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Client` (`num` INTEGER, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, PRIMARY KEY (`num`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AppointmentDao get appointmentDao {
    return _appointmentDaoInstance ??=
        _$AppointmentDao(database, changeListener);
  }

  @override
  ClientDao get clientDao {
    return _clientDaoInstance ??= _$ClientDao(database, changeListener);
  }
}

class _$AppointmentDao extends AppointmentDao {
  _$AppointmentDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _appointmentInsertionAdapter = InsertionAdapter(
            database,
            'Appointment',
            (Appointment item) => <String, Object?>{
                  'id': item.id,
                  'type': _appointmentTypeConverter.encode(item.type),
                  'time': _dateTimeConverter.encode(item.time),
                  'duration': _durationConverter.encode(item.duration),
                  'clientId': item.clientId
                }),
        _appointmentUpdateAdapter = UpdateAdapter(
            database,
            'Appointment',
            ['id'],
            (Appointment item) => <String, Object?>{
                  'id': item.id,
                  'type': _appointmentTypeConverter.encode(item.type),
                  'time': _dateTimeConverter.encode(item.time),
                  'duration': _durationConverter.encode(item.duration),
                  'clientId': item.clientId
                }),
        _appointmentDeletionAdapter = DeletionAdapter(
            database,
            'Appointment',
            ['id'],
            (Appointment item) => <String, Object?>{
                  'id': item.id,
                  'type': _appointmentTypeConverter.encode(item.type),
                  'time': _dateTimeConverter.encode(item.time),
                  'duration': _durationConverter.encode(item.duration),
                  'clientId': item.clientId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Appointment> _appointmentInsertionAdapter;

  final UpdateAdapter<Appointment> _appointmentUpdateAdapter;

  final DeletionAdapter<Appointment> _appointmentDeletionAdapter;

  @override
  Future<List<Appointment>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM Appointment',
        mapper: (Map<String, Object?> row) => Appointment(
            row['id'] as int?,
            _appointmentTypeConverter.decode(row['type'] as int),
            _dateTimeConverter.decode(row['time'] as int),
            _durationConverter.decode(row['duration'] as int),
            row['clientId'] as int));
  }

  @override
  Future<Appointment?> get(int id) async {
    return _queryAdapter.query('SELECT * FROM Appointment WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Appointment(
            row['id'] as int?,
            _appointmentTypeConverter.decode(row['type'] as int),
            _dateTimeConverter.decode(row['time'] as int),
            _durationConverter.decode(row['duration'] as int),
            row['clientId'] as int),
        arguments: [id]);
  }

  @override
  Future<int> insert(Appointment appointment) {
    return _appointmentInsertionAdapter.insertAndReturnId(
        appointment, OnConflictStrategy.abort);
  }

  @override
  Future<int> update(Appointment appointment) {
    return _appointmentUpdateAdapter.updateAndReturnChangedRows(
        appointment, OnConflictStrategy.abort);
  }

  @override
  Future<int> remove(Appointment appointment) {
    return _appointmentDeletionAdapter.deleteAndReturnChangedRows(appointment);
  }
}

class _$ClientDao extends ClientDao {
  _$ClientDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _clientInsertionAdapter = InsertionAdapter(
            database,
            'Client',
            (Client item) => <String, Object?>{
                  'num': item.num,
                  'firstName': item.firstName,
                  'lastName': item.lastName
                }),
        _clientUpdateAdapter = UpdateAdapter(
            database,
            'Client',
            ['num'],
            (Client item) => <String, Object?>{
                  'num': item.num,
                  'firstName': item.firstName,
                  'lastName': item.lastName
                }),
        _clientDeletionAdapter = DeletionAdapter(
            database,
            'Client',
            ['num'],
            (Client item) => <String, Object?>{
                  'num': item.num,
                  'firstName': item.firstName,
                  'lastName': item.lastName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Client> _clientInsertionAdapter;

  final UpdateAdapter<Client> _clientUpdateAdapter;

  final DeletionAdapter<Client> _clientDeletionAdapter;

  @override
  Future<List<Client>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM Client',
        mapper: (Map<String, Object?> row) => Client(row['num'] as int?,
            row['firstName'] as String, row['lastName'] as String));
  }

  @override
  Future<Client?> get(int num) async {
    return _queryAdapter.query('SELECT * FROM Client WHERE num = ?1',
        mapper: (Map<String, Object?> row) => Client(row['num'] as int?,
            row['firstName'] as String, row['lastName'] as String),
        arguments: [num]);
  }

  @override
  Future<int> insert(Client client) {
    return _clientInsertionAdapter.insertAndReturnId(
        client, OnConflictStrategy.abort);
  }

  @override
  Future<void> update(Client client) async {
    await _clientUpdateAdapter.update(client, OnConflictStrategy.abort);
  }

  @override
  Future<void> remove(Client client) async {
    await _clientDeletionAdapter.delete(client);
  }
}

// ignore_for_file: unused_element
final _appointmentTypeConverter = AppointmentTypeConverter();
final _dateTimeConverter = DateTimeConverter();
final _durationConverter = DurationConverter();
