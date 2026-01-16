import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../database/entity/budget.dart';
import '../database/entity/budget_transaction.dart';
import '../database/entity/currency.dart';
import '../providers/budget_transaction_provider.dart';
import '../services/settings_service.dart';
import 'add_budget_transaction_page.dart';

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

  double _calculateTotal() {
    double total = 0;
    for (var transaction in _transactions) {
      if (transaction.type == BudgetTransactionType.income) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
            Text('${l10n.type}: ${transaction.type == BudgetTransactionType.income ? l10n.income : l10n.expense}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(transaction.date)}'),
            if (transaction.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Tags: ${transaction.tags.join(", ")}'),
            ],
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
              await context.read<BudgetTransactionProvider>().removeTransaction(transaction);
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
    final total = _calculateTotal();
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Theme.of(context).colorScheme.surface : Colors.white;
    final cardColor = isDarkMode ? Theme.of(context).colorScheme.surfaceContainer : Colors.white;

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
          // Budget Summary Card - Remove elevation and make background transparent/white
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  l10n.totalBalance,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(total),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.arrow_upward, color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(
                            _transactions
                                .where(
                                  (t) => t.type == BudgetTransactionType.income,
                                )
                                .fold(0.0, (sum, t) => sum + t.amount),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          l10n.income,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.arrow_downward, color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(
                            _transactions
                                .where(
                                  (t) => t.type == BudgetTransactionType.expense,
                                )
                                .fold(0.0, (sum, t) => sum + t.amount),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          l10n.expense,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                          ),
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
                            onTap: () => _showTransactionDetails(transaction),
                            leading: CircleAvatar(
                              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                            title: Text(transaction.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatDate(transaction.date)),
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
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDarkMode ? Colors.grey.shade800 : Colors.black,
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
