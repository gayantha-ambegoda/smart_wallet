import 'package:floor/floor.dart';
import '../entity/budget.dart';

@dao
abstract class BudgetDao {
  @Query('SELECT * FROM Budget')
  Future<List<Budget>> findAllBudgets();

  @Query('SELECT * FROM Budget WHERE id = :id')
  Future<Budget?> findBudgetById(int id);

  @insert
  Future<void> insertBudget(Budget budget);

  @update
  Future<void> updateBudget(Budget budget);

  @delete
  Future<void> deleteBudget(Budget budget);
}
