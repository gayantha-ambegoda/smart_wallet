import 'package:floor/floor.dart';
import '../entity/budget_transaction.dart';

@dao
abstract class BudgetTransactionDao {
  @Query('SELECT * FROM BudgetTransaction')
  Future<List<BudgetTransaction>> findAllBudgetTransactions();

  @Query('SELECT * FROM BudgetTransaction WHERE id = :id')
  Future<BudgetTransaction?> findBudgetTransactionById(int id);

  @Query('SELECT * FROM BudgetTransaction WHERE budgetId = :budgetId')
  Future<List<BudgetTransaction>> findBudgetTransactionsByBudgetId(int budgetId);

  @Query(
    'SELECT SUM(amount) FROM BudgetTransaction WHERE type = \'income\' AND budgetId = :budgetId',
  )
  Future<double?> getTotalIncomeByBudget(int budgetId);

  @Query(
    'SELECT SUM(amount) FROM BudgetTransaction WHERE type = \'expense\' AND budgetId = :budgetId',
  )
  Future<double?> getTotalExpenseByBudget(int budgetId);

  @insert
  Future<void> insertBudgetTransaction(BudgetTransaction transaction);

  @update
  Future<void> updateBudgetTransaction(BudgetTransaction transaction);

  @delete
  Future<void> deleteBudgetTransaction(BudgetTransaction transaction);
}
