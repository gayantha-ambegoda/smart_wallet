import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../database/entity/transaction.dart';

class ModernTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currencySymbol;
  final String? budgetName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int?
  contextAccountId; // The account from which this transaction is being viewed

  const ModernTransactionCard({
    super.key,
    required this.transaction,
    required this.currencySymbol,
    this.budgetName,
    this.onTap,
    this.onLongPress,
    this.contextAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;

    // For transfers, determine if it's incoming or outgoing based on context
    // Priority: outgoing > incoming (for same-account transfers)
    final isTransferOutgoing =
        isTransfer &&
        contextAccountId != null &&
        transaction.accountId == contextAccountId;
    final isTransferIncoming =
        isTransfer &&
        contextAccountId != null &&
        transaction.toAccountId == contextAccountId &&
        !isTransferOutgoing; // Exclude if already marked as outgoing

    final date = DateTime.fromMillisecondsSinceEpoch(transaction.date);
    final dateStr = '${date.month}/${date.day}/${date.year}';
    final l10n = AppLocalizations.of(context)!;

    Color getColor() {
      if (isTransfer) {
        if (isTransferOutgoing) return Colors.red;
        if (isTransferIncoming) return Colors.green;
        return Colors.blue;
      }
      return isIncome ? Colors.green : Colors.red;
    }

    IconData getIcon() {
      if (isTransfer) {
        if (isTransferOutgoing) return Icons.arrow_upward;
        if (isTransferIncoming) return Icons.arrow_downward;
        return Icons.swap_horiz;
      }
      return isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    }

    String getTypeLabel() {
      if (isTransfer) {
        if (isTransferOutgoing) return l10n.transferOut;
        if (isTransferIncoming) return l10n.transferIn;
        return l10n.transfer;
      }
      return isIncome ? l10n.income : l10n.expense;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: getColor().withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(getIcon(), color: getColor(), size: 24),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (budgetName != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              budgetName!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (transaction.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: transaction.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isIncome
                        ? '+'
                        : isTransferOutgoing
                        ? '-'
                        : isTransferIncoming
                        ? '+'
                        : isTransfer
                        ? ''
                        : '-'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: getColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: getColor().withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      getTypeLabel(),
                      style: TextStyle(
                        fontSize: 11,
                        color: getColor(),
                        fontWeight: FontWeight.w500,
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
  }
}
