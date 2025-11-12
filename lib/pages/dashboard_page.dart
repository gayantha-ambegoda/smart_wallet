import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../database/entity/transaction.dart';
import '../database/entity/currency.dart';
import '../services/settings_service.dart';
import 'add_transaction_page.dart';
import 'budget_list_page.dart';
import 'settings_page.dart';

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
      _loadCurrency();
    });
  }

  Future<void> _loadCurrency() async {
    final currencyCode = await _settingsService.getCurrencyCode();
    final currency = CurrencyList.getByCode(currencyCode);
    setState(() {
      _currencySymbol = currency.symbol;
    });
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
      appBar: AppBar(
        title: _showTemplates
            ? const Text('Templates')
            : FutureBuilder<double>(
                future: context
                    .read<TransactionProvider>()
                    .getAvailableBalance(),
                builder: (context, snapshot) {
                  final availableBalance = snapshot.data ?? 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Dashboard'),
                      Text(
                        '$_currencySymbol${availableBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                },
              ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetListPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(_showTemplates ? Icons.list : Icons.description),
            onPressed: () {
              setState(() {
                _showTemplates = !_showTemplates;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              // Reload currency when returning from settings
              _loadCurrency();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Filter (only show when not in template mode)
            if (!_showTemplates)
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Filter by Date Range',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFromDate,
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                _fromDate == null
                                    ? 'From Date'
                                    : '${_fromDate!.month}/${_fromDate!.day}/${_fromDate!.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickToDate,
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                _toDate == null
                                    ? 'To Date'
                                    : '${_toDate!.month}/${_toDate!.day}/${_toDate!.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          if (_fromDate != null || _toDate != null)
                            IconButton(
                              onPressed: _clearDateFilter,
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear Filter',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, transactionProvider, child) {
                  final allTransactions = transactionProvider.transactions;
                  var transactions = _showTemplates
                      ? allTransactions.where((t) => t.isTemplate).toList()
                      : allTransactions.where((t) => !t.isTemplate).toList();

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
                  transactions.sort((a, b) => b.date.compareTo(a.date));

                  if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        _showTemplates
                            ? 'No templates yet'
                            : 'No transactions yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isIncome =
                          transaction.type == TransactionType.income;
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        transaction.date,
                      );
                      final dateStr = '${date.month}/${date.day}/${date.year}';

                      // Get budget name if budgetId exists
                      final budgetProvider = context.read<BudgetProvider>();
                      final budget = transaction.budgetId != null
                          ? budgetProvider.budgets.firstWhere(
                              (b) => b.id == transaction.budgetId,
                              orElse: () => budgetProvider.budgets.first,
                            )
                          : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          onLongPress: _showTemplates
                              ? () =>
                                    _createTransactionFromTemplate(transaction)
                              : null,
                          leading: CircleAvatar(
                            backgroundColor: isIncome
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              isIncome
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            transaction.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (budget != null) ...[
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.account_balance_wallet,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        budget.title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (transaction.tags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: transaction.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}$_currencySymbol${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isIncome ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isIncome ? 'Income' : 'Expense',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
