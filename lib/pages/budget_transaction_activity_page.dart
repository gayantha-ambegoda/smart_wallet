import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/entity/budget_transaction.dart';
import '../database/entity/currency.dart';
import '../database/entity/transaction.dart';
import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../services/settings_service.dart';
import '../widgets/modern_transaction_card.dart';

class BudgetTransactionActivityPage extends StatefulWidget {
  final BudgetTransaction budgetTransaction;

  const BudgetTransactionActivityPage({super.key, required this.budgetTransaction});

  @override
  State<BudgetTransactionActivityPage> createState() => _BudgetTransactionActivityPageState();
}

class _BudgetTransactionActivityPageState extends State<BudgetTransactionActivityPage> {
  final SettingsService _settingsService = SettingsService();
  bool _isLoading = true;
  String _currencySymbol = '\$';
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currencyCode = await _settingsService.getCurrencyCode();
    final currency = CurrencyList.getByCode(currencyCode);
    final txProvider = context.read<TransactionProvider>();
    final transactions = await txProvider.getTransactionsByBudgetTransactionId(
      widget.budgetTransaction.id ?? -1,
    );

    if (!mounted) return;
    setState(() {
      _currencySymbol = currency.symbol;
      _transactions = transactions;
      _isLoading = false;
    });
  }

  double _progressValue() {
    if (widget.budgetTransaction.type == BudgetTransactionType.income) {
      final totalIncome = _transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      return widget.budgetTransaction.amount == 0
          ? 0
          : (totalIncome / widget.budgetTransaction.amount).clamp(0, 1);
    } else {
      final spent = _transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      return widget.budgetTransaction.amount == 0
          ? 0
          : (spent / widget.budgetTransaction.amount).clamp(0, 1);
    }
  }

  String _progressLabel() {
    final isIncome = widget.budgetTransaction.type == BudgetTransactionType.income;
    final spent = _transactions
        .where((t) => t.type == (isIncome ? TransactionType.income : TransactionType.expense))
        .fold(0.0, (sum, t) => sum + t.amount);
    final total = widget.budgetTransaction.amount;
    return '${_currencySymbol}${spent.toStringAsFixed(2)}/$_currencySymbol${total.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Theme.of(context).colorScheme.surface
        : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.budgetTransaction.title),
        backgroundColor: backgroundColor,
        foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.budgetTransaction.type == BudgetTransactionType.income
                            ? l10n.income
                            : l10n.expense,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progressValue(),
                          minHeight: 12,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            widget.budgetTransaction.type == BudgetTransactionType.income
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.spentLabel}: ${_progressLabel()}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(child: Text(l10n.noTransactionsYet))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            return ModernTransactionCard(
                              transaction: tx,
                              currencySymbol: _currencySymbol,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
