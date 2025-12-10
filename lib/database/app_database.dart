import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/transaction_dao.dart';
import 'dao/budget_dao.dart';
import 'dao/account_dao.dart';
import 'entity/transaction.dart';
import 'entity/budget.dart';
import 'entity/account.dart';

part 'app_database.g.dart';

@Database(version: 3, entities: [Transaction, Budget, Account])
abstract class AppDatabase extends FloorDatabase {
  TransactionDao get transactionDao;
  BudgetDao get budgetDao;
  AccountDao get accountDao;
}
