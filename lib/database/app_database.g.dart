// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

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

  TransactionDao? _transactionDaoInstance;

  BudgetDao? _budgetDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
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
            'CREATE TABLE IF NOT EXISTS `Transaction` (`id` INTEGER, `title` TEXT NOT NULL, `amount` REAL NOT NULL, `date` INTEGER NOT NULL, `tags` TEXT NOT NULL, `type` TEXT NOT NULL, `isTemplate` INTEGER NOT NULL, `onlyBudget` INTEGER NOT NULL, `budgetId` INTEGER, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Budget` (`id` INTEGER, `title` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TransactionDao get transactionDao {
    return _transactionDaoInstance ??=
        _$TransactionDao(database, changeListener);
  }

  @override
  BudgetDao get budgetDao {
    return _budgetDaoInstance ??= _$BudgetDao(database, changeListener);
  }
}

class _$TransactionDao extends TransactionDao {
  _$TransactionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _transactionInsertionAdapter = InsertionAdapter(
            database,
            'Transaction',
            (Transaction item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'amount': item.amount,
                  'date': item.date,
                  'tags': _tagsConverter.encode(item.tags),
                  'type': _transactionTypeConverter.encode(item.type),
                  'isTemplate': item.isTemplate ? 1 : 0,
                  'onlyBudget': item.onlyBudget ? 1 : 0,
                  'budgetId': item.budgetId
                }),
        _transactionUpdateAdapter = UpdateAdapter(
            database,
            'Transaction',
            ['id'],
            (Transaction item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'amount': item.amount,
                  'date': item.date,
                  'tags': _tagsConverter.encode(item.tags),
                  'type': _transactionTypeConverter.encode(item.type),
                  'isTemplate': item.isTemplate ? 1 : 0,
                  'onlyBudget': item.onlyBudget ? 1 : 0,
                  'budgetId': item.budgetId
                }),
        _transactionDeletionAdapter = DeletionAdapter(
            database,
            'Transaction',
            ['id'],
            (Transaction item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'amount': item.amount,
                  'date': item.date,
                  'tags': _tagsConverter.encode(item.tags),
                  'type': _transactionTypeConverter.encode(item.type),
                  'isTemplate': item.isTemplate ? 1 : 0,
                  'onlyBudget': item.onlyBudget ? 1 : 0,
                  'budgetId': item.budgetId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Transaction> _transactionInsertionAdapter;

  final UpdateAdapter<Transaction> _transactionUpdateAdapter;

  final DeletionAdapter<Transaction> _transactionDeletionAdapter;

  @override
  Future<List<Transaction>> findAllTransactions() async {
    return _queryAdapter.queryList('SELECT * FROM `Transaction`',
        mapper: (Map<String, Object?> row) => Transaction(
            id: row['id'] as int?,
            title: row['title'] as String,
            amount: row['amount'] as double,
            date: row['date'] as int,
            tags: _tagsConverter.decode(row['tags'] as String),
            type: _transactionTypeConverter.decode(row['type'] as String),
            isTemplate: (row['isTemplate'] as int) != 0,
            onlyBudget: (row['onlyBudget'] as int) != 0,
            budgetId: row['budgetId'] as int?));
  }

  @override
  Future<Transaction?> findTransactionById(int id) async {
    return _queryAdapter.query('SELECT * FROM `Transaction` WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Transaction(
            id: row['id'] as int?,
            title: row['title'] as String,
            amount: row['amount'] as double,
            date: row['date'] as int,
            tags: _tagsConverter.decode(row['tags'] as String),
            type: _transactionTypeConverter.decode(row['type'] as String),
            isTemplate: (row['isTemplate'] as int) != 0,
            onlyBudget: (row['onlyBudget'] as int) != 0,
            budgetId: row['budgetId'] as int?),
        arguments: [id]);
  }

  @override
  Future<List<Transaction>> findTransactionsByBudgetId(int budgetId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM `Transaction` WHERE budgetId = ?1',
        mapper: (Map<String, Object?> row) => Transaction(
            id: row['id'] as int?,
            title: row['title'] as String,
            amount: row['amount'] as double,
            date: row['date'] as int,
            tags: _tagsConverter.decode(row['tags'] as String),
            type: _transactionTypeConverter.decode(row['type'] as String),
            isTemplate: (row['isTemplate'] as int) != 0,
            onlyBudget: (row['onlyBudget'] as int) != 0,
            budgetId: row['budgetId'] as int?),
        arguments: [budgetId]);
  }

  @override
  Future<double?> getTotalIncome() async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\'',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Future<double?> getTotalExpense() async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\'',
        mapper: (Map<String, Object?> row) => row.values.first as double);
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    await _transactionInsertionAdapter.insert(
        transaction, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionUpdateAdapter.update(
        transaction, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionDeletionAdapter.delete(transaction);
  }
}

class _$BudgetDao extends BudgetDao {
  _$BudgetDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _budgetInsertionAdapter = InsertionAdapter(
            database,
            'Budget',
            (Budget item) =>
                <String, Object?>{'id': item.id, 'title': item.title}),
        _budgetUpdateAdapter = UpdateAdapter(
            database,
            'Budget',
            ['id'],
            (Budget item) =>
                <String, Object?>{'id': item.id, 'title': item.title}),
        _budgetDeletionAdapter = DeletionAdapter(
            database,
            'Budget',
            ['id'],
            (Budget item) =>
                <String, Object?>{'id': item.id, 'title': item.title});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Budget> _budgetInsertionAdapter;

  final UpdateAdapter<Budget> _budgetUpdateAdapter;

  final DeletionAdapter<Budget> _budgetDeletionAdapter;

  @override
  Future<List<Budget>> findAllBudgets() async {
    return _queryAdapter.queryList('SELECT * FROM Budget',
        mapper: (Map<String, Object?> row) =>
            Budget(id: row['id'] as int?, title: row['title'] as String));
  }

  @override
  Future<Budget?> findBudgetById(int id) async {
    return _queryAdapter.query('SELECT * FROM Budget WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            Budget(id: row['id'] as int?, title: row['title'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    await _budgetInsertionAdapter.insert(budget, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _budgetUpdateAdapter.update(budget, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteBudget(Budget budget) async {
    await _budgetDeletionAdapter.delete(budget);
  }
}

// ignore_for_file: unused_element
final _tagsConverter = TagsConverter();
final _transactionTypeConverter = TransactionTypeConverter();
