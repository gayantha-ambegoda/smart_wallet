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
import '../utils/constants.dart';
import 'add_transaction_page.dart';
import 'budget_list_page.dart';
import 'settings_page.dart';
import 'account_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsService _settingsService = SettingsService();
  String _currencySymbol = '\$';
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<BudgetProvider>().loadBudgets();
      context.read<AccountProvider>().loadAccounts();
      _loadCurrency();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.account_balance,
                      color: account.isPrimary
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(StringUtils.truncateAccountName(account.name)),
                      if (account.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Primary',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('${account.bankName} • ${currency.code}'),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
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

  Widget _buildTransactionsList(bool showTemplates) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Consumer2<TransactionProvider, AccountProvider>(
        builder: (
          context,
          transactionProvider,
          accountProvider,
          child,
        ) {
          final allTransactions = transactionProvider.transactions;
          final selectedAccount = accountProvider.selectedAccount;

          var transactions = showTemplates
              ? allTransactions.where((t) => t.isTemplate).toList()
              : allTransactions
                  .where(
                    (t) => !t.isTemplate && !t.onlyBudget,
                  )
                  .toList();

          // Filter by selected account if one is selected
          if (!showTemplates && selectedAccount != null) {
            transactions = transactions
                .where(
                  (t) =>
                      t.accountId == selectedAccount.id ||
                      (t.type == TransactionType.transfer &&
                          t.toAccountId == selectedAccount.id),
                )
                .toList();
          }

          // Apply date range filter if dates are selected
          if (!showTemplates && (_fromDate != null || _toDate != null)) {
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
                    showTemplates
                        ? Icons.description_outlined
                        : Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    showTemplates ? l10n.noTemplatesYet : l10n.noTransactionsYet,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    showTemplates
                        ? l10n.createTemplateToGetStarted
                        : l10n.addTransactionToGetStarted,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: () {
              // Calculate item count: transactions + header items
              final headerItems = showTemplates ? 0 : 1; // filter card for transactions only
              return transactions.length + headerItems;
            }(),
            itemBuilder: (context, index) {
              // Date filter card (only when not in template mode)
              if (!showTemplates && index == 0) {
                return DateFilterCard(
                  fromDate: _fromDate,
                  toDate: _toDate,
                  onPickFromDate: _pickFromDate,
                  onPickToDate: _pickToDate,
                  onClearFilter: _clearDateFilter,
                );
              }

              // Transaction items
              final transactionIndex = showTemplates ? index : index - 1;
              final transaction = transactions[transactionIndex];

              // Get budget name if budgetId exists
              final budgetProvider = context.read<BudgetProvider>();
              final budget = transaction.budgetId != null
                  ? budgetProvider.budgets.firstWhere(
                      (b) => b.id == transaction.budgetId,
                      orElse: () => budgetProvider.budgets.first,
                    )
                  : null;

              return ModernTransactionCard(
                transaction: transaction,
                currencySymbol: _currencySymbol,
                budgetName: budget?.title,
                contextAccountId: selectedAccount?.id,
                onTap: showTemplates
                    ? () => _openTransactionFormFromTemplate(transaction)
                    : () => TransactionDetailsDialog.show(
                          context,
                          transaction,
                        ),
                onLongPress: null,
              );
            },
          );
        },
      ),
    );
  }

  void _openTransactionFormFromTemplate(Transaction template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          templateToUse: template,
        ),
      ),
    ).then((_) {
      // Reload transactions after returning
      if (mounted) {
        context.read<TransactionProvider>().loadTransactions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        elevation: 0,
        title: Consumer<AccountProvider>(
          builder: (context, accountProvider, child) {
            final selectedAccount = accountProvider.selectedAccount;
            final accounts = accountProvider.accounts;

            if (accounts.isEmpty) {
              return Text(
                l10n.dashboard,
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
                          StringUtils.truncateAccountName(selectedAccount.name),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          selectedAccount.bankName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ] else
                    Text(
                      l10n.dashboard,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
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
            tooltip: l10n.accounts,
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetListPage()),
              );
            },
            tooltip: l10n.budgets,
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
            tooltip: l10n.settings,
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
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.noAccountsYet,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.createAccountToGetStarted,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onErrorContainer,
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
                        child: Text(l10n.create),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Statistics Section
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface,
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
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.availableBalance,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_currencySymbol${balance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                                  color: Theme.of(context).colorScheme.tertiary,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.arrow_upward,
                                  label: l10n.totalExpense,
                                  value:
                                      '$_currencySymbol${expense.toStringAsFixed(2)}',
                                  color: Theme.of(context).colorScheme.error,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
          // Tab bar and list section
          Expanded(
            child: Column(
              children: [
                // Tab Bar
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: [
                      Tab(text: l10n.recentTransactions),
                      Tab(text: l10n.templates),
                    ],
                  ),
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
