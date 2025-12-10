import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/entity/account.dart';

class AccountProvider extends ChangeNotifier {
  final AppDatabase database;
  List<Account> _accounts = [];
  Account? _selectedAccount;

  AccountProvider(this.database);

  List<Account> get accounts => _accounts;
  Account? get selectedAccount => _selectedAccount;

  Future<void> loadAccounts() async {
    _accounts = await database.accountDao.findAllAccounts();
    
    // Set selected account to primary if available, otherwise first account
    if (_selectedAccount == null && _accounts.isNotEmpty) {
      _selectedAccount = await database.accountDao.findPrimaryAccount();
      _selectedAccount ??= _accounts.first;
    }
    
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    // If this is the first account or marked as primary, clear other primary flags
    if (account.isPrimary || _accounts.isEmpty) {
      await database.accountDao.clearAllPrimaryFlags();
    }
    
    await database.accountDao.insertAccount(account);
    await loadAccounts();
  }

  Future<void> updateAccountData(Account account) async {
    // If setting as primary, clear other primary flags
    if (account.isPrimary) {
      await database.accountDao.clearAllPrimaryFlags();
    }
    
    await database.accountDao.updateAccount(account);
    await loadAccounts();
  }

  Future<void> removeAccount(Account account) async {
    await database.accountDao.deleteAccount(account);
    
    // If the deleted account was selected, select another one
    if (_selectedAccount?.id == account.id) {
      _selectedAccount = null;
    }
    
    await loadAccounts();
  }

  void selectAccount(Account account) {
    _selectedAccount = account;
    notifyListeners();
  }

  Future<double> getAccountBalance(int accountId) async {
    final account = await database.accountDao.findAccountById(accountId);
    if (account == null) return 0.0;

    final transactions = await database.transactionDao.findTransactionsByAccountId(accountId);
    
    double balance = account.initialBalance;
    for (var transaction in transactions) {
      if (!transaction.isTemplate && !transaction.onlyBudget) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          balance -= transaction.amount;
        } else if (transaction.type == TransactionType.transfer) {
          // For transfers, deduct from source account
          // The destination account balance is updated separately when querying that account
          if (transaction.accountId == accountId) {
            balance -= transaction.amount;
          }
        }
      }
    }
    
    // Also check if this account is a destination for any transfers
    final allTransactions = await database.transactionDao.findAllTransactions();
    for (var transaction in allTransactions) {
      if (!transaction.isTemplate && 
          !transaction.onlyBudget && 
          transaction.type == TransactionType.transfer && 
          transaction.toAccountId == accountId) {
        // Add the converted amount to destination account
        double amountToAdd = transaction.amount;
        if (transaction.exchangeRate != null) {
          amountToAdd = transaction.amount * transaction.exchangeRate!;
        }
        balance += amountToAdd;
      }
    }
    
    return balance;
  }
}
