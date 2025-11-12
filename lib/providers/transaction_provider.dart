import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/entity/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final AppDatabase database;
  List<Transaction> _transactions = [];

  TransactionProvider(this.database);

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _transactions = await database.transactionDao.findAllTransactions();
    notifyListeners();
  }

  Future<List<Transaction>> getTransactionsByBudgetId(int budgetId) async {
    return await database.transactionDao.findTransactionsByBudgetId(budgetId);
  }

  Future<double> getAvailableBalance() async {
    final income = await database.transactionDao.getTotalIncome() ?? 0.0;
    final expense = await database.transactionDao.getTotalExpense() ?? 0.0;
    return income - expense;
  }

  Future<void> addTransaction(Transaction transaction) async {
    await database.transactionDao.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransactionData(Transaction transaction) async {
    await database.transactionDao.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> removeTransaction(Transaction transaction) async {
    await database.transactionDao.deleteTransaction(transaction);
    await loadTransactions();
  }
}
