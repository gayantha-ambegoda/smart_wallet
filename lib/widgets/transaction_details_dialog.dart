import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../database/entity/transaction.dart';
import '../database/entity/currency.dart';
import '../providers/transaction_provider.dart';
import '../services/settings_service.dart';
import '../pages/add_transaction_page.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTransactionChanged;

  const TransactionDetailsDialog({
    super.key,
    required this.transaction,
    this.onTransactionChanged,
  });

  static Future<void> show(
    BuildContext context,
    Transaction transaction, {
    VoidCallback? onTransactionChanged,
  }) {
    return showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        transaction: transaction,
        onTransactionChanged: onTransactionChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final SettingsService settingsService = SettingsService();
    final isIncome = transaction.type == TransactionType.income;
    final date = DateTime.fromMillisecondsSinceEpoch(transaction.date);
    final dateStr = '${date.month}/${date.day}/${date.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with colored background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isIncome ? l10n.income : l10n.expense,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<String>(
                      future: _getCurrencySymbol(settingsService),
                      builder: (context, snapshot) {
                        final currencySymbol = snapshot.data ?? '\$';
                        return Text(
                          '${isIncome ? '+' : '-'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _buildInfoSection(
                      icon: Icons.receipt_long,
                      label: 'Title',
                      value: transaction.title,
                    ),
                    const SizedBox(height: 20),

                    // Date
                    _buildInfoSection(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: dateStr,
                    ),
                    const SizedBox(height: 20),

                    // Tags
                    if (transaction.tags.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.label, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transaction.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Budget-only indicator
                    if (transaction.onlyBudget)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.purple.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 16,
                              color: Colors.purple.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Budget-Only Transaction',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (transaction.onlyBudget) const SizedBox(height: 20),

                    // Template indicator
                    if (transaction.isTemplate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Template Transaction',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Do Transaction button for budget-only transactions
                    if (transaction.onlyBudget) ...[
                      ElevatedButton.icon(
                        onPressed: () => _handleDoTransaction(context),
                        icon: const Icon(Icons.check_circle),
                        label: Text(l10n.doTransaction),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Update and Delete buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleDelete(context),
                            icon: const Icon(Icons.delete),
                            label: Text(l10n.delete),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleUpdate(context),
                            icon: const Icon(Icons.edit),
                            label: Text(l10n.update),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String> _getCurrencySymbol(SettingsService settingsService) async {
    final currencyCode = await settingsService.getCurrencyCode();
    final currency = CurrencyList.getByCode(currencyCode);
    return currency.symbol;
  }

  Future<void> _handleDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Text(l10n.confirmDelete),
            ],
          ),
          content: Text(l10n.deleteConfirmationMessage(transaction.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<TransactionProvider>().removeTransaction(transaction);

      if (context.mounted) {
        Navigator.pop(context); // Close the details dialog
        onTransactionChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(l10n.transactionDeletedSuccessfully),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleUpdate(BuildContext context) async {
    // Close the details dialog first and capture the callback
    final callback = onTransactionChanged;
    Navigator.pop(context);

    // Navigate to AddTransactionPage with the transaction to edit
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddTransactionPage(transactionToEdit: transaction),
      ),
    );

    // Refresh transactions after returning from edit page
    if (context.mounted) {
      await context.read<TransactionProvider>().loadTransactions();
      // Call the callback to refresh the budget detail page
      callback?.call();
    }
  }

  Future<void> _handleDoTransaction(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Text(l10n.confirmTransaction),
            ],
          ),
          content: Text(
            l10n.doTransactionConfirmationMessage(transaction.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.doTransaction),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      // Create a new transaction with onlyBudget set to false
      final updatedTransaction = Transaction(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        date: transaction.date,
        tags: transaction.tags,
        type: transaction.type,
        isTemplate: transaction.isTemplate,
        onlyBudget: false, // Set to false to make it count in actual balance
        accountId: transaction.accountId, // Preserve the account ID
        toAccountId: transaction
            .toAccountId, // Preserve the destination account ID for transfers
        exchangeRate: transaction
            .exchangeRate, // Preserve the exchange rate for transfers
      );

      await context.read<TransactionProvider>().updateTransactionData(
        updatedTransaction,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close the details dialog
        onTransactionChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(l10n.transactionExecutedSuccessfully),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
