import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/entity/budget.dart';
import '../database/entity/budget_transaction.dart';

class BudgetProvider extends ChangeNotifier {
  final AppDatabase database;
  List<Budget> _budgets = [];

  BudgetProvider(this.database);

  List<Budget> get budgets => _budgets;

  Future<void> loadBudgets() async {
    _budgets = await database.budgetDao.findAllBudgets();
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await database.budgetDao.insertBudget(budget);
    await loadBudgets();
  }

  Future<void> updateBudgetData(Budget budget) async {
    await database.budgetDao.updateBudget(budget);
    await loadBudgets();
  }

  Future<void> removeBudget(Budget budget) async {
    await database.budgetDao.deleteBudget(budget);
    await loadBudgets();
  }

  // Get statistics for a specific budget using the new BudgetTransaction table
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
