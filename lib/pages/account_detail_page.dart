import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../database/entity/account.dart';
import '../database/entity/transaction.dart';
import '../database/entity/currency.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../widgets/transaction_details_dialog.dart';
import 'add_transaction_page.dart';
import 'add_account_page.dart';

class AccountDetailPage extends StatefulWidget {
  final Account account;

  const AccountDetailPage({super.key, required this.account});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    // Get all transactions where this account is either the source or destination
    final transactions = await context
        .read<TransactionProvider>()
        .database
        .transactionDao
        .findTransactionsByAccountIdOrToAccountId(widget.account.id!);
    
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  double _calculateBalance() {
    double balance = widget.account.initialBalance;
    for (var transaction in _transactions) {
      if (transaction.onlyBudget) continue; // Skip budget-only transactions
      
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        balance -= transaction.amount;
      } else if (transaction.type == TransactionType.transfer) {
        // For transfers, check if this is the source or destination account
        if (transaction.accountId == widget.account.id) {
          // Money going out (deduct from source account)
          balance -= transaction.amount;
        } else if (transaction.toAccountId == widget.account.id) {
          // Money coming in (add to destination account with exchange rate)
          double amountToAdd = transaction.amount;
          if (transaction.exchangeRate != null) {
            amountToAdd = transaction.amount * transaction.exchangeRate!;
          }
          balance += amountToAdd;
        }
      }
    }
    return balance;
  }

  double _calculateTotalIncome() {
    double total = 0;
    for (var transaction in _transactions) {
      if (transaction.onlyBudget) continue;
      if (transaction.type == TransactionType.income) {
        total += transaction.amount;
      } else if (transaction.type == TransactionType.transfer &&
          transaction.toAccountId == widget.account.id) {
        // Add incoming transfer amount with exchange rate
        double amountToAdd = transaction.amount;
        if (transaction.exchangeRate != null) {
          amountToAdd = transaction.amount * transaction.exchangeRate!;
        }
        total += amountToAdd;
      }
    }
    return total;
  }

  double _calculateTotalExpense() {
    double total = 0;
    for (var transaction in _transactions) {
      if (transaction.onlyBudget) continue;
      if (transaction.type == TransactionType.expense) {
        total += transaction.amount;
      } else if (transaction.type == TransactionType.transfer &&
          transaction.accountId == widget.account.id) {
        total += transaction.amount;
      }
    }
    return total;
  }

  String _formatCurrency(double amount) {
    final currency = CurrencyList.getByCode(widget.account.currencyCode);
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }

  String _formatCurrencyWithSign(double amount, String sign) {
    final currency = CurrencyList.getByCode(widget.account.currencyCode);
    return '$sign${currency.symbol}${amount.toStringAsFixed(2)}';
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final balance = _calculateBalance();
    final totalIncome = _calculateTotalIncome();
    final totalExpense = _calculateTotalExpense();
    final l10n = AppLocalizations.of(context)!;
    final currency = CurrencyList.getByCode(widget.account.currencyCode);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.account.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddAccountPage(accountToEdit: widget.account),
                ),
              );
              // Reload page after edit
              if (mounted) {
                context.read<AccountProvider>().loadAccounts();
                Navigator.pop(context);
              }
            },
            tooltip: l10n.edit,
          ),
        ],
      ),
      body: Column(
        children: [
          // Account Summary Card
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Account Icon and Info
                CircleAvatar(
                  radius: 32,
                  backgroundColor: widget.account.isPrimary
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.account.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Primary',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  widget.account.bankName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currency.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 20),
                // Current Balance
                Text(
                  l10n.availableBalance,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(balance),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                // Income and Expense Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.green),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(totalIncome),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          l10n.income,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.red),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(totalExpense),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          l10n.expense,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.recentTransactions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _transactions.isEmpty
                            ? Center(child: Text(l10n.noTransactionsYet))
                            : RefreshIndicator(
                                onRefresh: _loadTransactions,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _transactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = _transactions[index];
                                    final isIncome =
                                        transaction.type ==
                                            TransactionType.income;
                                    final isTransfer =
                                        transaction.type ==
                                            TransactionType.transfer;
                                    final isTransferOut =
                                        isTransfer &&
                                        transaction.accountId ==
                                            widget.account.id;
                                    final isTransferIn =
                                        isTransfer &&
                                        transaction.toAccountId ==
                                            widget.account.id;

                                    Color getColor() {
                                      if (isTransfer) {
                                        if (isTransferOut) return Colors.red;
                                        if (isTransferIn) return Colors.green;
                                      }
                                      return isIncome
                                          ? Colors.green
                                          : Colors.red;
                                    }

                                    String getSign() {
                                      if (isIncome) return '+';
                                      if (isTransferOut) return '-';
                                      if (isTransferIn) return '+';
                                      return '-';
                                    }

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        onTap: () =>
                                            TransactionDetailsDialog.show(
                                          context,
                                          transaction,
                                          onTransactionChanged:
                                              _loadTransactions,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              getColor().withAlpha(25),
                                          child: Icon(
                                            isIncome
                                                ? Icons.arrow_downward
                                                : isTransferOut
                                                    ? Icons.arrow_upward
                                                    : isTransferIn
                                                        ? Icons.arrow_downward
                                                        : Icons.arrow_upward,
                                            color: getColor(),
                                          ),
                                        ),
                                        title: Text(transaction.title),
                                        subtitle: Text(
                                          _formatDate(transaction.date),
                                        ),
                                        trailing: Text(
                                          _formatCurrencyWithSign(
                                            transaction.amount,
                                            getSign(),
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: getColor(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(
                preselectedAccountId: widget.account.id,
              ),
            ),
          );
          // Reload transactions after returning from add page
          _loadTransactions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
