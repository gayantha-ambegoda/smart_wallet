import 'package:path/path.dart';
import 'package:smartwallet/models/account_model.dart';
import 'package:smartwallet/models/extended_transaction_model.dart';
import 'package:smartwallet/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;

  final String _budTbl = "budgets";
  final String _budId = "id";
  final String _budTitle = "title";
  final String _fromDt = "from_dt";
  final String _toDt = "to_dt";

  final String _accTbl = "accounts";
  final String _accId = "acc_id";
  final String _title = "acc_title";
  final String _description = "acc_description";
  final String _accType = "acc_acctype";

  final String _transTbl = "transactions";
  final String _transId = "trn_id";
  final String _transTitle = "trn_title";
  final String _transDate = "trn_date";
  final String _transFromAcc = "trn_from_account";
  final String _transToAcc = "trn_to_account";
  final String _budget = "trn_budget";
  final String _transAmount = "trn_amount";
  final String _transStatus = "trn_status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db2.db");
    final database =
        await openDatabase(databasePath, version: 2, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE $_accTbl (
        $_accId INTEGER PRIMARY KEY,
        $_title TEXT NOT NULL,
        $_description TEXT NOT NULL,
        $_accType INTEGER NOT NULL
        )
      ''');
      db.execute('''
        CREATE TABLE $_transTbl(
        $_transId INTEGER PRIMARY KEY,
        $_transTitle TEXT NOT NULL,
        $_transDate TEXT NOT NULL,
        $_transFromAcc INTEGER NOT NULL,
        $_transToAcc INTEGER NOT NULL,
        $_budget INTEGER NOT NULL,
        $_transAmount REAL,
        $_transStatus INTEGER NOT NULL
        )
      ''');
    });
    return database;
  }

  void addAccount(String title, String desc, int type) async {
    final db = await database;
    await db
        .insert(_accTbl, {_title: title, _description: desc, _accType: type});
  }

  Future<List<AccountModel>> getAccounts(int type) async {
    final db = await database;
    final data =
        await db.query(_accTbl, where: "$_accType = ? ", whereArgs: [type]);
    List<AccountModel> models = data
        .map((e) => AccountModel(
            id: e[_accId] as int,
            type: e[_accType] as int,
            title: e[_title] as String,
            description: e[_description] as String))
        .toList();
    return models;
  }

  Future<List<AccountModel>> getAllAccounts() async {
    final db = await database;
    final data = await db.query(_accTbl,
        where: "$_accType = ? or $_accType = ? ", whereArgs: [1, 2]);
    List<AccountModel> models = data
        .map((e) => AccountModel(
            id: e[_accId] as int,
            type: e[_accType] as int,
            title: e[_title] as String,
            description: e[_description] as String))
        .toList();
    return models;
  }

  Future<AccountModel> getAccount(int accId) async {
    final db = await database;
    final data =
        await db.query(_accTbl, where: "$_accId = ? ", whereArgs: [accId]);
    List<AccountModel> models = data
        .map((e) => AccountModel(
            id: e[_accId] as int,
            type: e[_accType] as int,
            title: e[_title] as String,
            description: e[_description] as String))
        .toList();
    return models.first;
  }

  void addTransaction(String title, String date, int fromAcc, int toAcc,
      int budget, double amount) async {
    var db = await database;
    await db.insert(_transTbl, {
      _transTitle: title,
      _transDate: date,
      _transFromAcc: fromAcc,
      _transToAcc: toAcc,
      _budget: budget,
      _transAmount: amount,
      _transStatus: 1
    });
  }

  Future<List<TransactionModel>> getAllTransactions(int account) async {
    final db = await database;
    final data = await db.query(_transTbl,
        where: "$_transFromAcc = ? or $_transToAcc = ? or $_budget = ? ",
        whereArgs: [account, account, account]);
    List<TransactionModel> models = data
        .map((e) => TransactionModel(
            id: 1,
            title: "hello",
            budget: 4,
            toAcc: 2,
            fromAcc: 1,
            status: 1,
            date: "dd",
            amount: 12))
        .toList();
    return models;
  }

  Future<List<ExtendedTransactionModel>> getAllExtendedTransactions(
      int account) async {
    final db = await database;
    final data = await db.rawQuery(
        '''select $_transTbl.*,acc1.$_title as from_title,acc2.$_title as to_title,acc3.$_title as bud_title from $_transTbl inner join $_accTbl as acc1 on acc1.$_accId = $_transTbl.$_transFromAcc inner join $_accTbl as acc2 on acc2.$_accId = $_transTbl.$_transToAcc inner join $_accTbl as acc3 on acc3.$_accId = $_transTbl.$_budget where $_transTbl.$_transFromAcc = $account or $_transTbl.$_transToAcc = $account or $_transTbl.$_budget = $account''');
    List<ExtendedTransactionModel> models = data
        .map((e) => ExtendedTransactionModel(
            id: e[_transId] as int,
            title: e[_transTitle] as String,
            budget: e[_budget] as int,
            toAcc: e[_transToAcc] as int,
            fromAcc: e[_transFromAcc] as int,
            fromAccTitle: e['from_title'] as String,
            toAccTitle: e['to_title'] as String,
            fromAccDes: 'not_retrieved',
            toAccDes: 'not_retrieved',
            budgetTitle: e['bud_title'] as String,
            budgetDes: 'not_retrieved',
            status: e[_transStatus] as int,
            date: e[_transDate] as String,
            amount: e[_transAmount] as double))
        .toList();
    return models;
  }
}
