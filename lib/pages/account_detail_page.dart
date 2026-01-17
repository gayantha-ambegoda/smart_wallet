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

class _AccountDetailPageState extends State<AccountDetailPage>
    with SingleTickerProviderStateMixin {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  // double _calculateBalance() {
  //   double balance = widget.account.initialBalance;
  //   for (var transaction in _transactions) {
  //     // Skip budget-only transactions and templates
  //     if (transaction.onlyBudget || transaction.isTemplate) continue;

  //     if (transaction.type == TransactionType.income) {
  //       balance += transaction.amount;
  //     } else if (transaction.type == TransactionType.expense) {
  //       balance -= transaction.amount;
  //     } else if (transaction.type == TransactionType.transfer) {
  //       // For transfers, check if this is the source or destination account
  //       if (transaction.accountId == widget.account.id) {
  //         // Money going out (deduct from source account)
  //         balance -= transaction.amount;
  //       } else if (transaction.toAccountId == widget.account.id) {
  //         // Money coming in (add to destination account with exchange rate)
  //         double amountToAdd = transaction.amount;
  //         if (transaction.exchangeRate != null) {
  //           amountToAdd = transaction.amount * transaction.exchangeRate!;
  //         }
  //         balance += amountToAdd;
  //       }
  //     }
  //   }
  //   return balance;
  // }

  double _calculateTotalIncome() {
    double total = 0;
    for (var transaction in _transactions) {
      // Skip budget-only transactions and templates
      if (transaction.onlyBudget || transaction.isTemplate) continue;
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
      // Skip budget-only transactions and templates
      if (transaction.onlyBudget || transaction.isTemplate) continue;
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

  Widget _buildTransactionsList(bool showTemplates) {
    final l10n = AppLocalizations.of(context)!;
    final filteredTransactions = _transactions
        .where(
          (t) => showTemplates ? t.isTemplate : !t.isTemplate && !t.onlyBudget,
        )
        .toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Text(
          showTemplates ? l10n.noTemplatesYet : l10n.noTransactionsYet,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          final isIncome = transaction.type == TransactionType.income;
          final isTransfer = transaction.type == TransactionType.transfer;
          final isTransferOut =
              isTransfer && transaction.accountId == widget.account.id;
          final isTransferIn =
              isTransfer && transaction.toAccountId == widget.account.id;

          Color getColor() {
            if (isTransfer) {
              if (isTransferOut) {
                return Theme.of(context).colorScheme.error;
              }
              if (isTransferIn) {
                return Theme.of(context).colorScheme.tertiary;
              }
            }
            return isIncome
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error;
          }

          Color getBackgroundColor() {
            if (isTransfer) {
              if (isTransferOut) {
                return Theme.of(context).colorScheme.errorContainer;
              }
              if (isTransferIn) {
                return Theme.of(context).colorScheme.tertiaryContainer;
              }
            }
            return isIncome
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Theme.of(context).colorScheme.errorContainer;
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
              onTap: showTemplates
                  ? () => _openTransactionFormFromTemplate(transaction)
                  : () => TransactionDetailsDialog.show(
                      context,
                      transaction,
                      onTransactionChanged: _loadTransactions,
                    ),
              leading: CircleAvatar(
                backgroundColor: getBackgroundColor(),
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
              subtitle: showTemplates
                  ? null
                  : Text(_formatDate(transaction.date)),
              trailing: Text(
                _formatCurrencyWithSign(transaction.amount, getSign()),
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
    );
  }

  void _openTransactionFormFromTemplate(Transaction template) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddTransactionPage(templateToUse: template),
          ),
        )
        .then((_) => _loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    // final balance = _calculateBalance();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: l10n.transfer,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTransactionPage(
                    preselectedAccountId: widget.account.id,
                    preselectedType: TransactionType.transfer,
                  ),
                ),
              );
              if (mounted) {
                _loadTransactions();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addTransaction,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTransactionPage(
                    preselectedAccountId: widget.account.id,
                  ),
                ),
              );
              if (mounted) {
                _loadTransactions();
              }
            },
          ),
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
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.10),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Account Icon and Info
                const SizedBox(height: 12),
                Text(
                  widget.account.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (widget.account.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.apartment, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            widget.account.bankName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.currency_exchange, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            currency.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Income and expense summary styled like dashboard cards
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.income,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatCurrency(totalIncome),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.expense,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatCurrency(totalExpense),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab bar and transactions/templates list
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: [
                      Tab(text: l10n.recentTransactions),
                      Tab(text: l10n.templates),
                    ],
                  ),
                  // Tab views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Transactions tab
                        _buildTransactionsList(false),
                        // Templates tab
                        _buildTransactionsList(true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
