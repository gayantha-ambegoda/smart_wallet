import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/entity/budget_transaction.dart';
import '../database/entity/currency.dart';
import '../database/entity/transaction.dart';
import '../l10n/app_localizations.dart';
import '../providers/budget_transaction_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/settings_service.dart';
import '../widgets/modern_transaction_card.dart';
import '../widgets/transaction_details_dialog.dart';

class TagTransactionsPage extends StatefulWidget {
  final String tag;

  const TagTransactionsPage({super.key, required this.tag});

  @override
  State<TagTransactionsPage> createState() => _TagTransactionsPageState();
}

class _TagTransactionsPageState extends State<TagTransactionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  List<Transaction> _transactions = [];
  List<BudgetTransaction> _budgetTransactions = [];
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final settingsService = SettingsService();
    final transactionProvider = context.read<TransactionProvider>();
    final budgetTransactionProvider = context.read<BudgetTransactionProvider>();

    await transactionProvider.loadTransactions();
    final allTransactions = transactionProvider.transactions;

    final budgetTransactions = await budgetTransactionProvider
        .getAllTransactions();

    final currencyCode = await settingsService.getCurrencyCode();
    final currency = CurrencyList.getByCode(currencyCode);

    final filteredTransactions =
        allTransactions
            .where(
              (tx) =>
                  tx.tags.contains(widget.tag) &&
                  tx.type != TransactionType.transfer &&
                  !tx.isTemplate &&
                  !tx.onlyBudget,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final filteredBudgetTransactions =
        budgetTransactions.where((tx) => tx.tags.contains(widget.tag)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;
    setState(() {
      _transactions = filteredTransactions;
      _budgetTransactions = filteredBudgetTransactions;
      _currencySymbol = currency.symbol;
      _isLoading = false;
    });
  }

  double _sumIncome(List<Transaction> list) {
    return list
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _sumExpense(List<Transaction> list) {
    return list
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _sumBudgetIncome(List<BudgetTransaction> list) {
    return list
        .where((tx) => tx.type == BudgetTransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _sumBudgetExpense(List<BudgetTransaction> list) {
    return list
        .where((tx) => tx.type == BudgetTransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  String _formatAmount(double value) {
    return '$_currencySymbol${value.toStringAsFixed(2)}';
  }

  Widget _buildSummary({required double income, required double expense}) {
    final l10n = AppLocalizations.of(context)!;
    final total = income - expense;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color totalColor;
    if (total > 0) {
      totalColor = Colors.green;
    } else if (total < 0) {
      totalColor = Colors.red;
    } else {
      totalColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                  _formatAmount(income),
                  style: TextStyle(
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
                  _formatAmount(expense),
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
                  _formatAmount(total),
                  style: TextStyle(
                    color: totalColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final l10n = AppLocalizations.of(context)!;
    final income = _sumIncome(_transactions);
    final expense = _sumExpense(_transactions);

    if (_transactions.isEmpty) {
      return Column(
        children: [
          _buildSummary(income: income, expense: expense),
          Expanded(child: Center(child: Text(l10n.noTransactionsYet))),
        ],
      );
    }

    return Column(
      children: [
        _buildSummary(income: income, expense: expense),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return ModernTransactionCard(
                transaction: transaction,
                currencySymbol: _currencySymbol,
                onTap: () => TransactionDetailsDialog.show(
                  context,
                  transaction,
                  onTransactionChanged: _loadData,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTransactionsTab() {
    final l10n = AppLocalizations.of(context)!;
    final income = _sumBudgetIncome(_budgetTransactions);
    final expense = _sumBudgetExpense(_budgetTransactions);

    if (_budgetTransactions.isEmpty) {
      return Column(
        children: [
          _buildSummary(income: income, expense: expense),
          Expanded(child: Center(child: Text(l10n.noTransactionsYet))),
        ],
      );
    }

    return Column(
      children: [
        _buildSummary(income: income, expense: expense),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _budgetTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _budgetTransactions[index];
              final isIncome = transaction.type == BudgetTransactionType.income;
              final date = DateTime.fromMillisecondsSinceEpoch(
                transaction.date,
              );
              final dateStr = '${date.month}/${date.day}/${date.year}';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isIncome ? Colors.green : Colors.red)
                        .withOpacity(0.1),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(transaction.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr),
                      if (transaction.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: transaction.tags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.tag}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Budget Transactions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsTab(),
                _buildBudgetTransactionsTab(),
              ],
            ),
    );
  }
}
