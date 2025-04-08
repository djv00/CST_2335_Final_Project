// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
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

  EventDao? _eventDaoInstance;

  CustomerDao? _customerDaoInstance;

  ExpenseDao? _expenseDaoInstance;

  MaintenanceDao? _maintenanceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `EventItem` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `date` TEXT NOT NULL, `time` TEXT NOT NULL, `location` TEXT NOT NULL, `description` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CustomerItem` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `birthday` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ExpenseItem` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `expenseName` TEXT NOT NULL, `category` TEXT NOT NULL, `amount` TEXT NOT NULL, `date` TEXT NOT NULL, `paymentMethod` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MaintenanceItem` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `vehicleName` TEXT NOT NULL, `vehicleType` TEXT NOT NULL, `serviceType` TEXT NOT NULL, `serviceDate` TEXT NOT NULL, `mileage` TEXT NOT NULL, `cost` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  EventDao get eventDao {
    return _eventDaoInstance ??= _$EventDao(database, changeListener);
  }

  @override
  CustomerDao get customerDao {
    return _customerDaoInstance ??= _$CustomerDao(database, changeListener);
  }

  @override
  ExpenseDao get expenseDao {
    return _expenseDaoInstance ??= _$ExpenseDao(database, changeListener);
  }

  @override
  MaintenanceDao get maintenanceDao {
    return _maintenanceDaoInstance ??=
        _$MaintenanceDao(database, changeListener);
  }
}

class _$EventDao extends EventDao {
  _$EventDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _eventItemInsertionAdapter = InsertionAdapter(
            database,
            'EventItem',
            (EventItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'date': item.date,
                  'time': item.time,
                  'location': item.location,
                  'description': item.description
                }),
        _eventItemUpdateAdapter = UpdateAdapter(
            database,
            'EventItem',
            ['id'],
            (EventItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'date': item.date,
                  'time': item.time,
                  'location': item.location,
                  'description': item.description
                }),
        _eventItemDeletionAdapter = DeletionAdapter(
            database,
            'EventItem',
            ['id'],
            (EventItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'date': item.date,
                  'time': item.time,
                  'location': item.location,
                  'description': item.description
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EventItem> _eventItemInsertionAdapter;

  final UpdateAdapter<EventItem> _eventItemUpdateAdapter;

  final DeletionAdapter<EventItem> _eventItemDeletionAdapter;

  @override
  Future<List<EventItem>> findAllEvents() async {
    return _queryAdapter.queryList('SELECT * FROM EventItem',
        mapper: (Map<String, Object?> row) => EventItem(
            row['id'] as int?,
            row['name'] as String,
            row['date'] as String,
            row['time'] as String,
            row['location'] as String,
            row['description'] as String));
  }

  @override
  Future<void> insertEvent(EventItem event) async {
    await _eventItemInsertionAdapter.insert(event, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEvent(EventItem event) async {
    await _eventItemUpdateAdapter.update(event, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEvent(EventItem event) async {
    await _eventItemDeletionAdapter.delete(event);
  }
}

class _$CustomerDao extends CustomerDao {
  _$CustomerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerItemInsertionAdapter = InsertionAdapter(
            database,
            'CustomerItem',
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': item.birthday
                }),
        _customerItemUpdateAdapter = UpdateAdapter(
            database,
            'CustomerItem',
            ['id'],
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': item.birthday
                }),
        _customerItemDeletionAdapter = DeletionAdapter(
            database,
            'CustomerItem',
            ['id'],
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': item.birthday
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CustomerItem> _customerItemInsertionAdapter;

  final UpdateAdapter<CustomerItem> _customerItemUpdateAdapter;

  final DeletionAdapter<CustomerItem> _customerItemDeletionAdapter;

  @override
  Future<List<CustomerItem>> findAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM CustomerItem',
        mapper: (Map<String, Object?> row) => CustomerItem(
            row['id'] as int?,
            row['firstName'] as String,
            row['lastName'] as String,
            row['address'] as String,
            row['birthday'] as String));
  }

  @override
  Future<void> insertCustomer(CustomerItem customer) async {
    await _customerItemInsertionAdapter.insert(
        customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(CustomerItem customer) async {
    await _customerItemUpdateAdapter.update(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(CustomerItem customer) async {
    await _customerItemDeletionAdapter.delete(customer);
  }
}

class _$ExpenseDao extends ExpenseDao {
  _$ExpenseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _expenseItemInsertionAdapter = InsertionAdapter(
            database,
            'ExpenseItem',
            (ExpenseItem item) => <String, Object?>{
                  'id': item.id,
                  'expenseName': item.expenseName,
                  'category': item.category,
                  'amount': item.amount,
                  'date': item.date,
                  'paymentMethod': item.paymentMethod
                }),
        _expenseItemUpdateAdapter = UpdateAdapter(
            database,
            'ExpenseItem',
            ['id'],
            (ExpenseItem item) => <String, Object?>{
                  'id': item.id,
                  'expenseName': item.expenseName,
                  'category': item.category,
                  'amount': item.amount,
                  'date': item.date,
                  'paymentMethod': item.paymentMethod
                }),
        _expenseItemDeletionAdapter = DeletionAdapter(
            database,
            'ExpenseItem',
            ['id'],
            (ExpenseItem item) => <String, Object?>{
                  'id': item.id,
                  'expenseName': item.expenseName,
                  'category': item.category,
                  'amount': item.amount,
                  'date': item.date,
                  'paymentMethod': item.paymentMethod
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExpenseItem> _expenseItemInsertionAdapter;

  final UpdateAdapter<ExpenseItem> _expenseItemUpdateAdapter;

  final DeletionAdapter<ExpenseItem> _expenseItemDeletionAdapter;

  @override
  Future<List<ExpenseItem>> findAllExpenses() async {
    return _queryAdapter.queryList('SELECT * FROM ExpenseItem',
        mapper: (Map<String, Object?> row) => ExpenseItem(
            row['id'] as int?,
            row['expenseName'] as String,
            row['category'] as String,
            row['amount'] as String,
            row['date'] as String,
            row['paymentMethod'] as String));
  }

  @override
  Future<void> insertExpense(ExpenseItem expense) async {
    await _expenseItemInsertionAdapter.insert(
        expense, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateExpense(ExpenseItem expense) async {
    await _expenseItemUpdateAdapter.update(expense, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteExpense(ExpenseItem expense) async {
    await _expenseItemDeletionAdapter.delete(expense);
  }
}

class _$MaintenanceDao extends MaintenanceDao {
  _$MaintenanceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _maintenanceItemInsertionAdapter = InsertionAdapter(
            database,
            'MaintenanceItem',
            (MaintenanceItem item) => <String, Object?>{
                  'id': item.id,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                }),
        _maintenanceItemUpdateAdapter = UpdateAdapter(
            database,
            'MaintenanceItem',
            ['id'],
            (MaintenanceItem item) => <String, Object?>{
                  'id': item.id,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                }),
        _maintenanceItemDeletionAdapter = DeletionAdapter(
            database,
            'MaintenanceItem',
            ['id'],
            (MaintenanceItem item) => <String, Object?>{
                  'id': item.id,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MaintenanceItem> _maintenanceItemInsertionAdapter;

  final UpdateAdapter<MaintenanceItem> _maintenanceItemUpdateAdapter;

  final DeletionAdapter<MaintenanceItem> _maintenanceItemDeletionAdapter;

  @override
  Future<List<MaintenanceItem>> findAllMaintenances() async {
    return _queryAdapter.queryList('SELECT * FROM MaintenanceItem',
        mapper: (Map<String, Object?> row) => MaintenanceItem(
            row['id'] as int?,
            row['vehicleName'] as String,
            row['vehicleType'] as String,
            row['serviceType'] as String,
            row['serviceDate'] as String,
            row['mileage'] as String,
            row['cost'] as String));
  }

  @override
  Future<void> insertMaintenance(MaintenanceItem maintenance) async {
    await _maintenanceItemInsertionAdapter.insert(
        maintenance, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMaintenance(MaintenanceItem maintenance) async {
    await _maintenanceItemUpdateAdapter.update(
        maintenance, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMaintenance(MaintenanceItem maintenance) async {
    await _maintenanceItemDeletionAdapter.delete(maintenance);
  }
}
