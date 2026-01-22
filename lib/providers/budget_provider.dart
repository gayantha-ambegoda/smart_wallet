import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/entity/budget.dart';

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

  /// Check if any transactions are linked to budget transactions for this budget
  Future<bool> hasLinkedTransactions(int budgetId) async {
    final budgetTransactions = await database.budgetTransactionDao
        .findBudgetTransactionsByBudgetId(budgetId);
    
    for (final budgetTransaction in budgetTransactions) {
      if (budgetTransaction.id != null) {
        final count = await database.transactionDao
            .countTransactionsByBudgetTransactionId(budgetTransaction.id!);
        if (count != null && count > 0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Delete budget and its budget transactions
  /// Returns true if successful, false if there are linked transactions
  Future<bool> deleteBudgetWithTransactions(Budget budget) async {
    if (budget.id == null) return false;
    
    // Check if there are linked transactions
    final hasLinked = await hasLinkedTransactions(budget.id!);
    if (hasLinked) {
      return false;
    }
    
    // Delete all budget transactions first
    final budgetTransactions = await database.budgetTransactionDao
        .findBudgetTransactionsByBudgetId(budget.id!);
    for (final transaction in budgetTransactions) {
      await database.budgetTransactionDao.deleteBudgetTransaction(transaction);
    }
    
    // Then delete the budget
    await database.budgetDao.deleteBudget(budget);
    await loadBudgets();
    return true;
  }

  /// Duplicate a budget and its budget transactions
  Future<void> duplicateBudget(Budget budget, String newTitle) async {
    if (budget.id == null) return;
    
    // Create new budget with new title
    final newBudget = Budget(title: newTitle);
    await database.budgetDao.insertBudget(newBudget);
    
    // Get the newly created budget to get its ID
    // We reload all budgets and find the one with the highest ID that matches the title
    await loadBudgets();
    final matchingBudgets = _budgets.where((b) => b.title == newTitle).toList();
    if (matchingBudgets.isEmpty) return;
    
    // Get the budget with the highest ID (most recently inserted)
    matchingBudgets.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    final createdBudget = matchingBudgets.first;
    
    if (createdBudget.id == null) return;
    
    // Get all budget transactions for the original budget
    final budgetTransactions = await database.budgetTransactionDao
        .findBudgetTransactionsByBudgetId(budget.id!);
    
    // Create copies of budget transactions for the new budget
    for (final transaction in budgetTransactions) {
      final newTransaction = BudgetTransaction(
        title: transaction.title,
        amount: transaction.amount,
        date: transaction.date,
        tags: transaction.tags,
        type: transaction.type,
        budgetId: createdBudget.id!,
      );
      await database.budgetTransactionDao.insertBudgetTransaction(newTransaction);
    }
    
    await loadBudgets();
  }

  // Get statistics for a specific budget using the new BudgetTransaction table
  Future<Map<String, double>> getBudgetStatistics(int budgetId) async {
    final totalIncome =
        await database.budgetTransactionDao.getTotalIncomeByBudget(budgetId) ??
        0.0;
    final totalExpense =
        await database.budgetTransactionDao.getTotalExpenseByBudget(budgetId) ??
        0.0;
    final totalSaved = totalIncome - totalExpense;

    return {
      'totalSaved': totalSaved,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
    };
  }
}
