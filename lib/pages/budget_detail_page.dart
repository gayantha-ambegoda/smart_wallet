import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../database/entity/budget.dart';
import '../database/entity/budget_transaction.dart';
import '../database/entity/currency.dart';
import '../providers/budget_transaction_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/settings_service.dart';
import 'add_budget_transaction_page.dart';
import 'add_transaction_page.dart';
import 'budget_transaction_activity_page.dart';

class BudgetDetailPage extends StatefulWidget {
  final Budget budget;

  const BudgetDetailPage({super.key, required this.budget});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  List<BudgetTransaction> _transactions = [];
  bool _isLoading = true;
  final SettingsService _settingsService = SettingsService();
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currencyCode = await _settingsService.getCurrencyCode();
    final currency = CurrencyList.getByCode(currencyCode);
    setState(() {
      _currencySymbol = currency.symbol;
    });
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final transactions = await context
        .read<BudgetTransactionProvider>()
        .getTransactionsByBudgetId(widget.budget.id!);
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  // double _calculateTotal() {
  //   double total = 0;
  //   for (var transaction in _transactions) {
  //     if (transaction.type == BudgetTransactionType.income) {
  //       total += transaction.amount;
  //     } else {
  //       total -= transaction.amount;
  //     }
  //   }
  //   return total;
  // }

  double _sumIncome() {
    return _transactions
        .where((t) => t.type == BudgetTransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _sumExpense() {
    return _transactions
        .where((t) => t.type == BudgetTransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  String _formatCurrency(double amount) {
    return '$_currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showTransactionDetails(BudgetTransaction transaction) {
    final l10n = AppLocalizations.of(context)!;
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.amount}: ${_formatCurrency(transaction.amount)}'),
            const SizedBox(height: 8),
            Text(
              '${l10n.type}: ${transaction.type == BudgetTransactionType.income ? l10n.income : l10n.expense}',
            ),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(transaction.date)}'),
            if (transaction.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Tags: ${transaction.tags.join(", ")}'),
            ],
            const SizedBox(height: 16),
            // Create Transaction button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionPage(
                        fromBudgetTransaction: transaction,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(l10n.createTransaction),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBudgetTransactionPage(
                    budgetId: widget.budget.id!,
                    transactionToEdit: transaction,
                  ),
                ),
              ).then((_) => _loadTransactions());
            },
            child: Text(l10n.edit),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<BudgetTransactionProvider>().removeTransaction(
                transaction,
              );
              _loadTransactions();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final income = _sumIncome();
    final expense = _sumExpense();
    final total = income - expense;
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
    final cardColor = isDarkMode
        ? Theme.of(context).colorScheme.surfaceContainer
        : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.budget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddBudgetTransactionPage(budgetId: widget.budget.id!),
                ),
              );
              // Reload transactions after returning from add page
              _loadTransactions();
            },
            tooltip: l10n.addTransaction,
          ),
        ],
      ),
      body: Column(
        children: [
          // Budget Summary - matches tag transactions summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.income,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(income),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.expense,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(expense),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.totalBalance,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(total),
                        style: TextStyle(
                          color: total > 0
                              ? Colors.green
                              : total < 0
                              ? Colors.red
                              : isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                ? Center(child: Text(l10n.noTransactionsYet))
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        final isIncome =
                            transaction.type == BudgetTransactionType.income;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                           child: ListTile(
                             onLongPress: () => _showTransactionDetails(transaction),
                             onTap: () {
                               Navigator.of(context).push(
                                 MaterialPageRoute(
                                   builder: (context) => BudgetTransactionActivityPage(
                                     budgetTransaction: transaction,
                                   ),
                                 ),
                               );
                             },
                             leading: CircleAvatar(
                              backgroundColor: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                            title: Text(transaction.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDate(transaction.date)),
                                  FutureBuilder<int>(
                                    future: transaction.id == null
                                        ? Future.value(0)
                                        : context
                                            .read<TransactionProvider>()
                                            .countTransactionsByBudgetTransactionId(
                                              transaction.id!,
                                            ),
                                    builder: (context, snapshot) {
                                      final count = snapshot.data ?? 0;
                                      if (count == 0) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$count ${l10n.transactions}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (transaction.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                    children: transaction.tags
                                        .map(
                                          (tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDarkMode
                                                    ? Colors.grey.shade800
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
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
    );
  }
}
