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
    database.database = await database.open(path, _migrations, _callback);
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TransactionDao? _transactionDaoInstance;

  BudgetDao? _budgetDaoInstance;

  AccountDao? _accountDaoInstance;

  BudgetTransactionDao? _budgetTransactionDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
          database,
          startVersion,
          endVersion,
          migrations,
        );

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `Transaction` (`id` INTEGER, `title` TEXT NOT NULL, `amount` REAL NOT NULL, `date` INTEGER NOT NULL, `tags` TEXT NOT NULL, `type` TEXT NOT NULL, `isTemplate` INTEGER NOT NULL, `onlyBudget` INTEGER NOT NULL, `accountId` INTEGER, `toAccountId` INTEGER, `exchangeRate` REAL, `budgetTransactionId` INTEGER, PRIMARY KEY (`id`))',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `Budget` (`id` INTEGER, `title` TEXT NOT NULL, PRIMARY KEY (`id`))',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `Account` (`id` INTEGER, `name` TEXT NOT NULL, `bankName` TEXT NOT NULL, `currencyCode` TEXT NOT NULL, `initialBalance` REAL NOT NULL, `isPrimary` INTEGER NOT NULL, PRIMARY KEY (`id`))',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `BudgetTransaction` (`id` INTEGER, `title` TEXT NOT NULL, `amount` REAL NOT NULL, `date` INTEGER NOT NULL, `tags` TEXT NOT NULL, `type` TEXT NOT NULL, `budgetId` INTEGER NOT NULL, PRIMARY KEY (`id`))',
        );

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TransactionDao get transactionDao {
    return _transactionDaoInstance ??= _$TransactionDao(
      database,
      changeListener,
    );
  }

  @override
  BudgetDao get budgetDao {
    return _budgetDaoInstance ??= _$BudgetDao(database, changeListener);
  }

  @override
  AccountDao get accountDao {
    return _accountDaoInstance ??= _$AccountDao(database, changeListener);
  }

  @override
  BudgetTransactionDao get budgetTransactionDao {
    return _budgetTransactionDaoInstance ??= _$BudgetTransactionDao(database, changeListener);
  }
}

class _$TransactionDao extends TransactionDao {
  _$TransactionDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
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
          'accountId': item.accountId,
          'toAccountId': item.toAccountId,
          'exchangeRate': item.exchangeRate,
          'budgetTransactionId': item.budgetTransactionId,
        },
      ),
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
          'accountId': item.accountId,
          'toAccountId': item.toAccountId,
          'exchangeRate': item.exchangeRate,
          'budgetTransactionId': item.budgetTransactionId,
        },
      ),
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
          'accountId': item.accountId,
          'toAccountId': item.toAccountId,
          'exchangeRate': item.exchangeRate,
          'budgetTransactionId': item.budgetTransactionId,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Transaction> _transactionInsertionAdapter;

  final UpdateAdapter<Transaction> _transactionUpdateAdapter;

  final DeletionAdapter<Transaction> _transactionDeletionAdapter;

  @override
  Future<List<Transaction>> findAllTransactions() async {
    return _queryAdapter.queryList(
      'SELECT * FROM `Transaction`',
      mapper: (Map<String, Object?> row) => Transaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _tagsConverter.decode(row['tags'] as String),
        type: _transactionTypeConverter.decode(row['type'] as String),
        isTemplate: (row['isTemplate'] as int) != 0,
        onlyBudget: (row['onlyBudget'] as int) != 0,
        accountId: row['accountId'] as int?,
        toAccountId: row['toAccountId'] as int?,
        exchangeRate: row['exchangeRate'] as double?,
        budgetTransactionId: row['budgetTransactionId'] as int?,
      ),
    );
  }

  @override
  Future<Transaction?> findTransactionById(int id) async {
    return _queryAdapter.query(
      'SELECT * FROM `Transaction` WHERE id = ?1',
      mapper: (Map<String, Object?> row) => Transaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _tagsConverter.decode(row['tags'] as String),
        type: _transactionTypeConverter.decode(row['type'] as String),
        isTemplate: (row['isTemplate'] as int) != 0,
        onlyBudget: (row['onlyBudget'] as int) != 0,
        accountId: row['accountId'] as int?,
        toAccountId: row['toAccountId'] as int?,
        exchangeRate: row['exchangeRate'] as double?,
        budgetTransactionId: row['budgetTransactionId'] as int?,
      ),
      arguments: [id],
    );
  }

  @override
  Future<List<Transaction>> findTransactionsByAccountId(int accountId) async {
    return _queryAdapter.queryList(
      'SELECT * FROM `Transaction` WHERE accountId = ?1',
      mapper: (Map<String, Object?> row) => Transaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _tagsConverter.decode(row['tags'] as String),
        type: _transactionTypeConverter.decode(row['type'] as String),
        isTemplate: (row['isTemplate'] as int) != 0,
        onlyBudget: (row['onlyBudget'] as int) != 0,
        accountId: row['accountId'] as int?,
        toAccountId: row['toAccountId'] as int?,
        exchangeRate: row['exchangeRate'] as double?,
        budgetTransactionId: row['budgetTransactionId'] as int?,
      ),
      arguments: [accountId],
    );
  }

  @override
  Future<List<Transaction>> findTransactionsByAccountIdOrToAccountId(
    int accountId,
  ) async {
    return _queryAdapter.queryList(
      'SELECT * FROM `Transaction` WHERE accountId = ?1 OR toAccountId = ?1',
      mapper: (Map<String, Object?> row) => Transaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _tagsConverter.decode(row['tags'] as String),
        type: _transactionTypeConverter.decode(row['type'] as String),
        isTemplate: (row['isTemplate'] as int) != 0,
        onlyBudget: (row['onlyBudget'] as int) != 0,
        accountId: row['accountId'] as int?,
        toAccountId: row['toAccountId'] as int?,
        exchangeRate: row['exchangeRate'] as double?,
        budgetTransactionId: row['budgetTransactionId'] as int?,
      ),
      arguments: [accountId],
    );
  }

  @override
  Future<double?> getTotalIncomeByAccount(int accountId) async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\' AND accountId = ?1',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
      arguments: [accountId],
    );
  }

  @override
  Future<double?> getTotalExpenseByAccount(int accountId) async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\' AND accountId = ?1',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
      arguments: [accountId],
    );
  }

  @override
  Future<double?> getTotalIncome() async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\'',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
    );
  }

  @override
  Future<double?> getTotalExpense() async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\'',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
    );
  }

  @override
  Future<int?> getActualTransactionCount() async {
    return _queryAdapter.query(
      'SELECT COUNT(*) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0',
      mapper: (Map<String, Object?> row) => row.values.first as int,
    );
  }

  @override
  Future<List<Transaction>> getActualTransactions() async {
    return _queryAdapter.queryList(
      'SELECT * FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 ORDER BY date DESC',
      mapper: (Map<String, Object?> row) => Transaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _tagsConverter.decode(row['tags'] as String),
        type: _transactionTypeConverter.decode(row['type'] as String),
        isTemplate: (row['isTemplate'] as int) != 0,
        onlyBudget: (row['onlyBudget'] as int) != 0,
        accountId: row['accountId'] as int?,
        toAccountId: row['toAccountId'] as int?,
        exchangeRate: row['exchangeRate'] as double?,
        budgetTransactionId: row['budgetTransactionId'] as int?,
      ),
    );
  }

  @override
  Future<double?> getTotalIncomeInRange(int fromDate, int toDate) async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\' AND date >= ?1 AND date <= ?2',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
      arguments: [fromDate, toDate],
    );
  }

  @override
  Future<double?> getTotalExpenseInRange(int fromDate, int toDate) async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\' AND date >= ?1 AND date <= ?2',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
      arguments: [fromDate, toDate],
    );
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    await _transactionInsertionAdapter.insert(
      transaction,
      OnConflictStrategy.abort,
    );
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionUpdateAdapter.update(
      transaction,
      OnConflictStrategy.abort,
    );
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionDeletionAdapter.delete(transaction);
  }
}

class _$BudgetDao extends BudgetDao {
  _$BudgetDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _budgetInsertionAdapter = InsertionAdapter(
        database,
        'Budget',
        (Budget item) => <String, Object?>{'id': item.id, 'title': item.title},
      ),
      _budgetUpdateAdapter = UpdateAdapter(
        database,
        'Budget',
        ['id'],
        (Budget item) => <String, Object?>{'id': item.id, 'title': item.title},
      ),
      _budgetDeletionAdapter = DeletionAdapter(
        database,
        'Budget',
        ['id'],
        (Budget item) => <String, Object?>{'id': item.id, 'title': item.title},
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Budget> _budgetInsertionAdapter;

  final UpdateAdapter<Budget> _budgetUpdateAdapter;

  final DeletionAdapter<Budget> _budgetDeletionAdapter;

  @override
  Future<List<Budget>> findAllBudgets() async {
    return _queryAdapter.queryList(
      'SELECT * FROM Budget',
      mapper: (Map<String, Object?> row) =>
          Budget(id: row['id'] as int?, title: row['title'] as String),
    );
  }

  @override
  Future<Budget?> findBudgetById(int id) async {
    return _queryAdapter.query(
      'SELECT * FROM Budget WHERE id = ?1',
      mapper: (Map<String, Object?> row) =>
          Budget(id: row['id'] as int?, title: row['title'] as String),
      arguments: [id],
    );
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

class _$AccountDao extends AccountDao {
  _$AccountDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _accountInsertionAdapter = InsertionAdapter(
        database,
        'Account',
        (Account item) => <String, Object?>{
          'id': item.id,
          'name': item.name,
          'bankName': item.bankName,
          'currencyCode': item.currencyCode,
          'initialBalance': item.initialBalance,
          'isPrimary': item.isPrimary ? 1 : 0,
        },
      ),
      _accountUpdateAdapter = UpdateAdapter(
        database,
        'Account',
        ['id'],
        (Account item) => <String, Object?>{
          'id': item.id,
          'name': item.name,
          'bankName': item.bankName,
          'currencyCode': item.currencyCode,
          'initialBalance': item.initialBalance,
          'isPrimary': item.isPrimary ? 1 : 0,
        },
      ),
      _accountDeletionAdapter = DeletionAdapter(
        database,
        'Account',
        ['id'],
        (Account item) => <String, Object?>{
          'id': item.id,
          'name': item.name,
          'bankName': item.bankName,
          'currencyCode': item.currencyCode,
          'initialBalance': item.initialBalance,
          'isPrimary': item.isPrimary ? 1 : 0,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Account> _accountInsertionAdapter;

  final UpdateAdapter<Account> _accountUpdateAdapter;

  final DeletionAdapter<Account> _accountDeletionAdapter;

  @override
  Future<List<Account>> findAllAccounts() async {
    return _queryAdapter.queryList(
      'SELECT * FROM Account',
      mapper: (Map<String, Object?> row) => Account(
        id: row['id'] as int?,
        name: row['name'] as String,
        bankName: row['bankName'] as String,
        currencyCode: row['currencyCode'] as String,
        initialBalance: row['initialBalance'] as double,
        isPrimary: (row['isPrimary'] as int) != 0,
      ),
    );
  }

  @override
  Future<Account?> findAccountById(int id) async {
    return _queryAdapter.query(
      'SELECT * FROM Account WHERE id = ?1',
      mapper: (Map<String, Object?> row) => Account(
        id: row['id'] as int?,
        name: row['name'] as String,
        bankName: row['bankName'] as String,
        currencyCode: row['currencyCode'] as String,
        initialBalance: row['initialBalance'] as double,
        isPrimary: (row['isPrimary'] as int) != 0,
      ),
      arguments: [id],
    );
  }

  @override
  Future<Account?> findPrimaryAccount() async {
    return _queryAdapter.query(
      'SELECT * FROM Account WHERE isPrimary = 1',
      mapper: (Map<String, Object?> row) => Account(
        id: row['id'] as int?,
        name: row['name'] as String,
        bankName: row['bankName'] as String,
        currencyCode: row['currencyCode'] as String,
        initialBalance: row['initialBalance'] as double,
        isPrimary: (row['isPrimary'] as int) != 0,
      ),
    );
  }

  @override
  Future<void> insertAccount(Account account) async {
    await _accountInsertionAdapter.insert(account, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAccount(Account account) async {
    await _accountUpdateAdapter.update(account, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAccount(Account account) async {
    await _accountDeletionAdapter.delete(account);
  }

  @override
  Future<void> clearAllPrimaryFlags() async {
    await _queryAdapter.queryNoReturn('UPDATE Account SET isPrimary = 0');
  }
}

class _$BudgetTransactionDao extends BudgetTransactionDao {
  _$BudgetTransactionDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _budgetTransactionInsertionAdapter = InsertionAdapter(
        database,
        'BudgetTransaction',
        (BudgetTransaction item) => <String, Object?>{
          'id': item.id,
          'title': item.title,
          'amount': item.amount,
          'date': item.date,
          'tags': _budgetTagsConverter.encode(item.tags),
          'type': _budgetTransactionTypeConverter.encode(item.type),
          'budgetId': item.budgetId,
        },
      ),
      _budgetTransactionUpdateAdapter = UpdateAdapter(
        database,
        'BudgetTransaction',
        ['id'],
        (BudgetTransaction item) => <String, Object?>{
          'id': item.id,
          'title': item.title,
          'amount': item.amount,
          'date': item.date,
          'tags': _budgetTagsConverter.encode(item.tags),
          'type': _budgetTransactionTypeConverter.encode(item.type),
          'budgetId': item.budgetId,
        },
      ),
      _budgetTransactionDeletionAdapter = DeletionAdapter(
        database,
        'BudgetTransaction',
        ['id'],
        (BudgetTransaction item) => <String, Object?>{
          'id': item.id,
          'title': item.title,
          'amount': item.amount,
          'date': item.date,
          'tags': _budgetTagsConverter.encode(item.tags),
          'type': _budgetTransactionTypeConverter.encode(item.type),
          'budgetId': item.budgetId,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<BudgetTransaction> _budgetTransactionInsertionAdapter;

  final UpdateAdapter<BudgetTransaction> _budgetTransactionUpdateAdapter;

  final DeletionAdapter<BudgetTransaction> _budgetTransactionDeletionAdapter;

  @override
  Future<List<BudgetTransaction>> findAllBudgetTransactions() async {
    return _queryAdapter.queryList(
      'SELECT * FROM BudgetTransaction',
      mapper: (Map<String, Object?> row) => BudgetTransaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _budgetTagsConverter.decode(row['tags'] as String),
        type: _budgetTransactionTypeConverter.decode(row['type'] as String),
        budgetId: row['budgetId'] as int,
      ),
    );
  }

  @override
  Future<BudgetTransaction?> findBudgetTransactionById(int id) async {
    return _queryAdapter.query(
      'SELECT * FROM BudgetTransaction WHERE id = ?1',
      mapper: (Map<String, Object?> row) => BudgetTransaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _budgetTagsConverter.decode(row['tags'] as String),
        type: _budgetTransactionTypeConverter.decode(row['type'] as String),
        budgetId: row['budgetId'] as int,
      ),
      arguments: [id],
    );
  }

  @override
  Future<List<BudgetTransaction>> findBudgetTransactionsByBudgetId(int budgetId) async {
    return _queryAdapter.queryList(
      'SELECT * FROM BudgetTransaction WHERE budgetId = ?1',
      mapper: (Map<String, Object?> row) => BudgetTransaction(
        id: row['id'] as int?,
        title: row['title'] as String,
        amount: row['amount'] as double,
        date: row['date'] as int,
        tags: _budgetTagsConverter.decode(row['tags'] as String),
        type: _budgetTransactionTypeConverter.decode(row['type'] as String),
        budgetId: row['budgetId'] as int,
      ),
      arguments: [budgetId],
    );
  }

  @override
  Future<double?> getTotalIncomeByBudget(int budgetId) async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM BudgetTransaction WHERE type = \'income\' AND budgetId = ?1',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
      arguments: [budgetId],
    );
  }

  @override
  Future<double?> getTotalExpenseByBudget(int budgetId) async {
    return _queryAdapter.query(
      'SELECT SUM(amount) FROM BudgetTransaction WHERE type = \'expense\' AND budgetId = ?1',
      mapper: (Map<String, Object?> row) =>
          (row.values.first as double?) ?? 0.0,
      arguments: [budgetId],
    );
  }

  @override
  Future<void> insertBudgetTransaction(BudgetTransaction transaction) async {
    await _budgetTransactionInsertionAdapter.insert(
      transaction,
      OnConflictStrategy.abort,
    );
  }

  @override
  Future<void> updateBudgetTransaction(BudgetTransaction transaction) async {
    await _budgetTransactionUpdateAdapter.update(
      transaction,
      OnConflictStrategy.abort,
    );
  }

  @override
  Future<void> deleteBudgetTransaction(BudgetTransaction transaction) async {
    await _budgetTransactionDeletionAdapter.delete(transaction);
  }
}

// ignore_for_file: unused_element
final _tagsConverter = TagsConverter();
final _transactionTypeConverter = TransactionTypeConverter();
final _budgetTagsConverter = BudgetTagsConverter();
final _budgetTransactionTypeConverter = BudgetTransactionTypeConverter();
