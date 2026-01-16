import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_transaction_provider.dart';

class TagsListPage extends StatefulWidget {
  const TagsListPage({super.key});

  @override
  State<TagsListPage> createState() => _TagsListPageState();
}

class _TagsListPageState extends State<TagsListPage> {
  List<String> _allTags = [];
  Map<String, int> _tagCounts = {};

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final transactionProvider = context.read<TransactionProvider>();
    final budgetTransactionProvider = context.read<BudgetTransactionProvider>();

    // Get all transactions
    final transactions = transactionProvider.transactions;
    
    // Get all budget transactions
    final budgetTransactions = await budgetTransactionProvider.getAllTransactions();

    // Collect all tags
    final Set<String> uniqueTags = {};
    final Map<String, int> counts = {};

    // From regular transactions
    for (var transaction in transactions) {
      for (var tag in transaction.tags) {
        if (tag.isNotEmpty) {
          uniqueTags.add(tag);
          counts[tag] = (counts[tag] ?? 0) + 1;
        }
      }
    }

    // From budget transactions
    for (var transaction in budgetTransactions) {
      for (var tag in transaction.tags) {
        if (tag.isNotEmpty) {
          uniqueTags.add(tag);
          counts[tag] = (counts[tag] ?? 0) + 1;
        }
      }
    }

    setState(() {
      _allTags = uniqueTags.toList()..sort();
      _tagCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Theme.of(context).colorScheme.surface : Colors.white;
    final cardColor = isDarkMode ? Theme.of(context).colorScheme.surfaceContainer : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.tags,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
      ),
      body: _allTags.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tags yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tags will appear here from your transactions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allTags.length,
              itemBuilder: (context, index) {
                final tag = _allTags[index];
                final count = _tagCounts[tag] ?? 0;

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
                    leading: CircleAvatar(
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: Icon(
                        Icons.label,
                        color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                    title: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
