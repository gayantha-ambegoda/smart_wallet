import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/entity/budget_transaction.dart';

class BudgetTransactionProvider extends ChangeNotifier {
  final AppDatabase database;
  List<BudgetTransaction> _transactions = [];

  BudgetTransactionProvider(this.database);

  List<BudgetTransaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _transactions = await database.budgetTransactionDao.findAllBudgetTransactions();
    notifyListeners();
  }

  Future<List<BudgetTransaction>> getTransactionsByBudgetId(int budgetId) async {
    return await database.budgetTransactionDao.findBudgetTransactionsByBudgetId(budgetId);
  }

  Future<List<BudgetTransaction>> getAllTransactions() async {
    return await database.budgetTransactionDao.findAllBudgetTransactions();
  }

  Future<void> addTransaction(BudgetTransaction transaction) async {
    await database.budgetTransactionDao.insertBudgetTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(BudgetTransaction transaction) async {
    await database.budgetTransactionDao.updateBudgetTransaction(transaction);
    await loadTransactions();
  }

  Future<void> removeTransaction(BudgetTransaction transaction) async {
    await database.budgetTransactionDao.deleteBudgetTransaction(transaction);
    await loadTransactions();
  }

  // Get statistics for a specific budget
  Future<Map<String, double>> getBudgetStatistics(int budgetId) async {
    final totalIncome = await database.budgetTransactionDao.getTotalIncomeByBudget(budgetId) ?? 0.0;
    final totalExpense = await database.budgetTransactionDao.getTotalExpenseByBudget(budgetId) ?? 0.0;
    final totalSaved = totalIncome - totalExpense;

    return {
      'totalSaved': totalSaved,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
    };
  }
}
