import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/entity/budget.dart';
import '../database/entity/transaction.dart';

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

  // Get statistics for a specific budget
  Future<Map<String, double>> getBudgetStatistics(int budgetId) async {
    final transactions = await database.transactionDao
        .findTransactionsByBudgetId(budgetId);
    
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (var transaction in transactions) {
      // Only count non-template transactions
      if (!transaction.isTemplate) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpense += transaction.amount;
        }
      }
    }
    
    double totalSaved = totalIncome - totalExpense;
    
    return {
      'totalSaved': totalSaved,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
    };
  }
}
