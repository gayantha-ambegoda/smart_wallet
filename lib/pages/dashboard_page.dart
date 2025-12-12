import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/account_provider.dart';
import '../database/entity/transaction.dart';
import '../database/entity/currency.dart';
import '../services/settings_service.dart';
import '../widgets/transaction_details_dialog.dart';
import '../widgets/stat_card.dart';
import '../widgets/modern_transaction_card.dart';
import '../widgets/date_filter_card.dart';
import '../widgets/expandable_fab.dart';
import 'add_transaction_page.dart';
import 'budget_list_page.dart';
import 'settings_page.dart';
import 'account_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showTemplates = false;
  final SettingsService _settingsService = SettingsService();
  String _currencySymbol = '\$';
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<BudgetProvider>().loadBudgets();
      context.read<AccountProvider>().loadAccounts();
      _loadCurrency();
    });
  }

  Future<void> _loadCurrency() async {
    final accountProvider = context.read<AccountProvider>();
    final selectedAccount = accountProvider.selectedAccount;

    if (selectedAccount != null) {
      final currency = CurrencyList.getByCode(selectedAccount.currencyCode);
      setState(() {
        _currencySymbol = currency.symbol;
      });
    } else {
      // Fallback to settings currency
      final currencyCode = await _settingsService.getCurrencyCode();
      final currency = CurrencyList.getByCode(currencyCode);
      setState(() {
        _currencySymbol = currency.symbol;
      });
    }
  }

  void _showAccountSelector(
    BuildContext context,
    AccountProvider accountProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectAccount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...accountProvider.accounts.map((account) {
                final currency = CurrencyList.getByCode(account.currencyCode);
                final isSelected =
                    accountProvider.selectedAccount?.id == account.id;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: account.isPrimary
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(account.name),
                      if (account.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('${account.bankName} • ${currency.code}'),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    accountProvider.selectAccount(account);
                    Navigator.pop(context);
                    setState(() {
                      _loadCurrency(); // Update currency symbol for selected account
                    });
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  Future<void> _createTransactionFromTemplate(Transaction template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add as Transaction'),
          content: Text(
            'Create a new transaction from "${template.title}" template?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final newTransaction = Transaction(
        title: template.title,
        amount: template.amount,
        date: DateTime.now().millisecondsSinceEpoch,
        tags: template.tags,
        type: template.type,
        isTemplate: false,
        onlyBudget: false, // Created from dashboard, not budget-specific
        budgetId: template.budgetId,
      );

      await context.read<TransactionProvider>().addTransaction(newTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created from template'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Consumer<AccountProvider>(
          builder: (context, accountProvider, child) {
            final selectedAccount = accountProvider.selectedAccount;
            final accounts = accountProvider.accounts;

            if (accounts.isEmpty) {
              return Text(
                _showTemplates ? 'Templates' : 'Dashboard',
                style: const TextStyle(fontWeight: FontWeight.w600),
              );
            }

            return GestureDetector(
              onTap: () {
                _showAccountSelector(context, accountProvider);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedAccount != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedAccount.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          selectedAccount.bankName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ] else
                    Text(
                      _showTemplates ? 'Templates' : 'Dashboard',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountListPage(),
                ),
              );
              // Reload accounts when returning
              if (mounted) {
                // ignore: use_build_context_synchronously
                context.read<AccountProvider>().loadAccounts();
              }
            },
            tooltip: 'Accounts',
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetListPage()),
              );
            },
            tooltip: 'Budgets',
          ),
          IconButton(
            icon: Icon(
              _showTemplates ? Icons.list : Icons.description_outlined,
            ),
            onPressed: () {
              setState(() {
                _showTemplates = !_showTemplates;
              });
            },
            tooltip: _showTemplates ? 'Show Transactions' : 'Show Templates',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              // Reload currency when returning from settings
              _loadCurrency();
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Show message when no accounts exist
          Consumer<AccountProvider>(
            builder: (context, accountProvider, child) {
              if (accountProvider.accounts.isEmpty) {
                return Container(
                  width: double.infinity,
                  color: Colors.orange.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No accounts yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create an account to start tracking your transactions',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountListPage(),
                            ),
                          );
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            context.read<AccountProvider>().loadAccounts();
                          }
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Statistics Section (only show when not in template mode)
          if (!_showTemplates)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Consumer2<TransactionProvider, AccountProvider>(
                builder: (context, transactionProvider, accountProvider, child) {
                  final selectedAccount = accountProvider.selectedAccount;

                  return FutureBuilder<Map<String, double>>(
                    future: selectedAccount != null
                        ? accountProvider
                              .getAccountBalance(selectedAccount.id!)
                              .then((balance) async {
                                final income =
                                    await transactionProvider
                                        .database
                                        .transactionDao
                                        .getTotalIncomeByAccount(
                                          selectedAccount.id!,
                                        ) ??
                                    0.0;
                                final expense =
                                    await transactionProvider
                                        .database
                                        .transactionDao
                                        .getTotalExpenseByAccount(
                                          selectedAccount.id!,
                                        ) ??
                                    0.0;
                                return {
                                  'balance': balance,
                                  'income': income,
                                  'expense': expense,
                                };
                              })
                        : Future.wait([
                            transactionProvider.getAvailableBalance(),
                            transactionProvider.getTotalIncome(),
                            transactionProvider.getTotalExpense(),
                          ]).then(
                            (values) => {
                              'balance': values[0],
                              'income': values[1],
                              'expense': values[2],
                            },
                          ),
                    builder: (context, snapshot) {
                      final balance = snapshot.data?['balance'] ?? 0.0;
                      final income = snapshot.data?['income'] ?? 0.0;
                      final expense = snapshot.data?['expense'] ?? 0.0;
                      final l10n = AppLocalizations.of(context)!;

                      return Column(
                        children: [
                          // Available Balance - Large display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withAlpha(25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.availableBalance,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_currencySymbol${balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Income and Expense cards
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.arrow_downward,
                                  label: l10n.totalIncome,
                                  value:
                                      '$_currencySymbol${income.toStringAsFixed(2)}',
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.arrow_upward,
                                  label: l10n.totalExpense,
                                  value:
                                      '$_currencySymbol${expense.toStringAsFixed(2)}',
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          // Transactions List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Filter (only show when not in template mode)
                  if (!_showTemplates)
                    DateFilterCard(
                      fromDate: _fromDate,
                      toDate: _toDate,
                      onPickFromDate: _pickFromDate,
                      onPickToDate: _pickToDate,
                      onClearFilter: _clearDateFilter,
                    ),
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _showTemplates ? 'Templates' : 'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  // Transaction List
                  Expanded(
                    child: Consumer2<TransactionProvider, AccountProvider>(
                      builder:
                          (
                            context,
                            transactionProvider,
                            accountProvider,
                            child,
                          ) {
                            final allTransactions =
                                transactionProvider.transactions;
                            final selectedAccount =
                                accountProvider.selectedAccount;

                            var transactions = _showTemplates
                                ? allTransactions
                                      .where((t) => t.isTemplate)
                                      .toList()
                                : allTransactions
                                      .where(
                                        (t) => !t.isTemplate && !t.onlyBudget,
                                      )
                                      .toList();

                            // Filter by selected account if one is selected
                            if (!_showTemplates && selectedAccount != null) {
                              transactions = transactions
                                  .where(
                                    (t) =>
                                        t.accountId == selectedAccount.id ||
                                        (t.type == TransactionType.transfer &&
                                            t.toAccountId ==
                                                selectedAccount.id),
                                  )
                                  .toList();
                            }

                            // Apply date range filter if dates are selected
                            if (!_showTemplates &&
                                (_fromDate != null || _toDate != null)) {
                              transactions = transactions.where((t) {
                                final transactionDate =
                                    DateTime.fromMillisecondsSinceEpoch(t.date);

                                // Check from date
                                if (_fromDate != null) {
                                  final fromStart = DateTime(
                                    _fromDate!.year,
                                    _fromDate!.month,
                                    _fromDate!.day,
                                  );
                                  if (transactionDate.isBefore(fromStart)) {
                                    return false;
                                  }
                                }

                                // Check to date
                                if (_toDate != null) {
                                  final toEnd = DateTime(
                                    _toDate!.year,
                                    _toDate!.month,
                                    _toDate!.day,
                                    23,
                                    59,
                                    59,
                                  );
                                  if (transactionDate.isAfter(toEnd)) {
                                    return false;
                                  }
                                }

                                return true;
                              }).toList();
                            }

                            // Sort transactions by date in descending order (latest first)
                            transactions.sort(
                              (a, b) => b.date.compareTo(a.date),
                            );

                            if (transactions.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _showTemplates
                                          ? Icons.description_outlined
                                          : Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _showTemplates
                                          ? 'No templates yet'
                                          : 'No transactions yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _showTemplates
                                          ? 'Create a template to get started'
                                          : 'Add a transaction to get started',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];

                                // Get budget name if budgetId exists
                                final budgetProvider = context
                                    .read<BudgetProvider>();
                                final budget = transaction.budgetId != null
                                    ? budgetProvider.budgets.firstWhere(
                                        (b) => b.id == transaction.budgetId,
                                        orElse: () =>
                                            budgetProvider.budgets.first,
                                      )
                                    : null;

                                return ModernTransactionCard(
                                  transaction: transaction,
                                  currencySymbol: _currencySymbol,
                                  budgetName: budget?.title,
                                  contextAccountId: selectedAccount?.id,
                                  onTap: _showTemplates
                                      ? null
                                      : () => TransactionDetailsDialog.show(
                                          context,
                                          transaction,
                                        ),
                                  onLongPress: _showTemplates
                                      ? () => _createTransactionFromTemplate(
                                          transaction,
                                        )
                                      : null,
                                );
                              },
                            );
                          },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ExpandableFab(
        onTransactionPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
          // Refresh transactions after returning from add page
          if (mounted) {
            // ignore: use_build_context_synchronously
            context.read<TransactionProvider>().loadTransactions();
          }
        },
        onTransferPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionPage(
                preselectedType: TransactionType.transfer,
              ),
            ),
          );
          // Refresh transactions after returning from add page
          if (mounted) {
            // ignore: use_build_context_synchronously
            context.read<TransactionProvider>().loadTransactions();
          }
        },
      ),
    );
  }
}
