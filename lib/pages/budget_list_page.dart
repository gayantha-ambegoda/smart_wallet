import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/budget_provider.dart';
import '../services/settings_service.dart';
import '../database/entity/currency.dart';
import 'add_budget_page.dart';
import 'budget_detail_page.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  final SettingsService _settingsService = SettingsService();
  String _currencySymbol = '\$';
  
  static const Map<String, double> _defaultStats = {
    'totalSaved': 0.0,
    'totalIncome': 0.0,
    'totalExpense': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  Future<void> _loadCurrency() async {
    final currencyCode = await _settingsService.getCurrencyCode();
    final currency = CurrencyList.getByCode(currencyCode);
    setState(() {
      _currencySymbol = currency.symbol;
    });
  }

  String _formatCurrency(double amount) {
    return '$_currencySymbol${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.budgets,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            final budgets = budgetProvider.budgets;

            if (budgets.isEmpty) {
              return Center(child: Text(l10n.noBudgetsYet));
            }

            return ListView.builder(
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return FutureBuilder<Map<String, double>>(
                  future: budgetProvider.getBudgetStatistics(budget.id!),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ?? _defaultStats;
                    final totalSaved = stats['totalSaved']!;
                    final totalIncome = stats['totalIncome']!;
                    final totalExpense = stats['totalExpense']!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  BudgetDetailPage(budget: budget),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Budget title
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      budget.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Total saved amount
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: totalSaved >= 0
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: totalSaved >= 0
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.totalBalance,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(totalSaved),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: totalSaved >= 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Income and Expense row
                              Row(
                                children: [
                                  // Income
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_upward,
                                                color: Colors.green.shade700,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.income,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatCurrency(totalIncome),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Expense
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_downward,
                                                color: Colors.red.shade700,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.expense,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatCurrency(totalExpense),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBudgetPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
