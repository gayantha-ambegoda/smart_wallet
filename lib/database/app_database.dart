import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/transaction_dao.dart';
import 'dao/budget_dao.dart';
import 'entity/transaction.dart';
import 'entity/budget.dart';

part 'app_database.g.dart';

@Database(version: 2, entities: [Transaction, Budget])
abstract class AppDatabase extends FloorDatabase {
  TransactionDao get transactionDao;
  BudgetDao get budgetDao;
}
