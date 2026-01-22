import 'package:floor/floor.dart';
import '../entity/transaction.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM `Transaction`')
  Future<List<Transaction>> findAllTransactions();

  @Query('SELECT * FROM `Transaction` WHERE id = :id')
  Future<Transaction?> findTransactionById(int id);

  @Query('SELECT * FROM `Transaction` WHERE accountId = :accountId')
  Future<List<Transaction>> findTransactionsByAccountId(int accountId);

  @Query(
    'SELECT * FROM `Transaction` WHERE accountId = :accountId OR toAccountId = :accountId',
  )
  Future<List<Transaction>> findTransactionsByAccountIdOrToAccountId(
    int accountId,
  );

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\' AND accountId = :accountId',
  )
  Future<double?> getTotalIncomeByAccount(int accountId);

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\' AND accountId = :accountId',
  )
  Future<double?> getTotalExpenseByAccount(int accountId);

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\'',
  )
  Future<double?> getTotalIncome();

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\'',
  )
  Future<double?> getTotalExpense();

  @Query(
    'SELECT COUNT(*) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0',
  )
  Future<int?> getActualTransactionCount();

  @Query(
    'SELECT * FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 ORDER BY date DESC',
  )
  Future<List<Transaction>> getActualTransactions();

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'income\' AND date >= :fromDate AND date <= :toDate',
  )
  Future<double?> getTotalIncomeInRange(int fromDate, int toDate);

  @Query(
    'SELECT SUM(amount) FROM `Transaction` WHERE isTemplate = 0 AND onlyBudget = 0 AND type = \'expense\' AND date >= :fromDate AND date <= :toDate',
  )
  Future<double?> getTotalExpenseInRange(int fromDate, int toDate);

  @insert
  Future<void> insertTransaction(Transaction transaction);

  @update
  Future<void> updateTransaction(Transaction transaction);

  @delete
  Future<void> deleteTransaction(Transaction transaction);

  @Query(
    'SELECT COUNT(*) FROM `Transaction` WHERE budgetTransactionId = :budgetTransactionId',
  )
  Future<int?> countTransactionsByBudgetTransactionId(int budgetTransactionId);
}
