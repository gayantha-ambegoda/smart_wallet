import 'package:floor/floor.dart';
import '../entity/transaction.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM `Transaction`')
  Future<List<Transaction>> findAllTransactions();

  @Query('SELECT * FROM `Transaction` WHERE id = :id')
  Future<Transaction?> findTransactionById(int id);

  @Query('SELECT * FROM `Transaction` WHERE budgetId = :budgetId')
  Future<List<Transaction>> findTransactionsByBudgetId(int budgetId);

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\'',
  )
  Future<double?> getTotalIncome();

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\'',
  )
  Future<double?> getTotalExpense();

  @insert
  Future<void> insertTransaction(Transaction transaction);

  @update
  Future<void> updateTransaction(Transaction transaction);

  @delete
  Future<void> deleteTransaction(Transaction transaction);
}
