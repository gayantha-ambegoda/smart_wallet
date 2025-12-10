import 'package:floor/floor.dart';
import '../entity/account.dart';

@dao
abstract class AccountDao {
  @Query('SELECT * FROM Account')
  Future<List<Account>> findAllAccounts();

  @Query('SELECT * FROM Account WHERE id = :id')
  Future<Account?> findAccountById(int id);

  @Query('SELECT * FROM Account WHERE isPrimary = 1')
  Future<Account?> findPrimaryAccount();

  @insert
  Future<void> insertAccount(Account account);

  @update
  Future<void> updateAccount(Account account);

  @delete
  Future<void> deleteAccount(Account account);

  @Query('UPDATE Account SET isPrimary = 0')
  Future<void> clearAllPrimaryFlags();
}
