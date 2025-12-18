import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../database/entity/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/account_provider.dart';
import '../database/entity/currency.dart';

class AddTransactionPage extends StatefulWidget {
  final int? preselectedBudgetId;
  final Transaction? transactionToEdit;
  final TransactionType? preselectedType;

  const AddTransactionPage({
    super.key,
    this.preselectedBudgetId,
    this.transactionToEdit,
    this.preselectedType,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _tagsController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  bool _isTemplate = false;
  int? _selectedBudgetId;
  int? _selectedAccountId;
  int? _toAccountId; // For transfers
  final _exchangeRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the preselected budget ID if provided
    _selectedBudgetId = widget.preselectedBudgetId;

    // Set the preselected transaction type if provided
    if (widget.preselectedType != null) {
      _selectedType = widget.preselectedType!;
    }

    // If editing an existing transaction, pre-fill the form
    if (widget.transactionToEdit != null) {
      final transaction = widget.transactionToEdit!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _tagsController.text = transaction.tags.join(', ');
      _selectedType = transaction.type;
      _isTemplate = transaction.isTemplate;
      _selectedBudgetId = transaction.budgetId;
      _selectedAccountId = transaction.accountId;
      _toAccountId = transaction.toAccountId;
      if (transaction.exchangeRate != null) {
        _exchangeRateController.text = transaction.exchangeRate.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _tagsController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionToEdit != null;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isEditing ? l10n.updateTransaction : l10n.addTransaction,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAmount;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.type,
                  border: const OutlineInputBorder(),
                ),
                items: TransactionType.values.map((type) {
                  String typeLabel;
                  switch (type) {
                    case TransactionType.income:
                      typeLabel = l10n.income;
                      break;
                    case TransactionType.expense:
                      typeLabel = l10n.expense;
                      break;
                    case TransactionType.transfer:
                      typeLabel = l10n.transfer;
                      break;
                  }
                  return DropdownMenuItem(value: type, child: Text(typeLabel));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Account selection
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final accounts = accountProvider.accounts;
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: l10n.fromAccount,
                      border: const OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      final currency = CurrencyList.getByCode(
                        account.currencyCode,
                      );
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text('${account.name} (${currency.code})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return l10n.pleaseSelectAccount;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Show "To Account" and exchange rate for transfers
              if (_selectedType == TransactionType.transfer) ...[
                Consumer<AccountProvider>(
                  builder: (context, accountProvider, child) {
                    final accounts = accountProvider.accounts;
                    return DropdownButtonFormField<int>(
                      initialValue: _toAccountId,
                      decoration: InputDecoration(
                        labelText: l10n.toAccount,
                        border: const OutlineInputBorder(),
                      ),
                      items: accounts
                          .where((account) => account.id != _selectedAccountId)
                          .map((account) {
                            final currency = CurrencyList.getByCode(
                              account.currencyCode,
                            );
                            return DropdownMenuItem(
                              value: account.id,
                              child: Text('${account.name} (${currency.code})'),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _toAccountId = value;
                          // Check if currencies are different
                          if (_selectedAccountId != null && value != null) {
                            final fromAccount = accounts.firstWhere(
                              (a) => a.id == _selectedAccountId,
                            );
                            final toAccount = accounts.firstWhere(
                              (a) => a.id == value,
                            );
                            if (fromAccount.currencyCode !=
                                toAccount.currencyCode) {
                              // Show exchange rate field
                              _exchangeRateController.text = '1.0';
                            } else {
                              _exchangeRateController.clear();
                            }
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return l10n.pleaseSelectDestinationAccount;
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Exchange rate field (only show if currencies are different)
                if (_selectedAccountId != null && _toAccountId != null)
                  Consumer<AccountProvider>(
                    builder: (context, accountProvider, child) {
                      final fromAccount = accountProvider.accounts.firstWhere(
                        (a) => a.id == _selectedAccountId,
                      );
                      final toAccount = accountProvider.accounts.firstWhere(
                        (a) => a.id == _toAccountId,
                      );

                      if (fromAccount.currencyCode != toAccount.currencyCode) {
                        return TextFormField(
                          controller: _exchangeRateController,
                          decoration: InputDecoration(
                            labelText: l10n.exchangeRate,
                            border: const OutlineInputBorder(),
                            helperText:
                                '1 ${fromAccount.currencyCode} = X ${toAccount.currencyCode}',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterExchangeRate;
                            }
                            if (double.tryParse(value) == null) {
                              return l10n.pleaseEnterValidNumber;
                            }
                            return null;
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                if (_exchangeRateController.text.isNotEmpty)
                  const SizedBox(height: 16),
              ],
              // Only show budget dropdown if no budget is preselected
              if (widget.preselectedBudgetId == null)
                Consumer<BudgetProvider>(
                  builder: (context, budgetProvider, child) {
                    final budgets = budgetProvider.budgets;
                    return DropdownButtonFormField<int>(
                      initialValue: _selectedBudgetId,
                      decoration: InputDecoration(
                        labelText: l10n.budgetOptional,
                        border: const OutlineInputBorder(),
                      ),
                      items: budgets.map((budget) {
                        return DropdownMenuItem(
                          value: budget.id,
                          child: Text(budget.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBudgetId = value;
                        });
                      },
                    );
                  },
                ),
              if (widget.preselectedBudgetId == null)
                const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: l10n.tagsCommaSeparated,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.isTemplate),
                value: _isTemplate,
                onChanged: (value) {
                  setState(() {
                    _isTemplate = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                  isEditing ? l10n.updateTransaction : l10n.saveTransaction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // onlyBudget should be false to ensure transaction appears in account list
      // Transactions from budgets should still be visible in account transactions
      final onlyBudget = false;

      double? exchangeRate;
      if (_selectedType == TransactionType.transfer &&
          _exchangeRateController.text.isNotEmpty) {
        exchangeRate = double.tryParse(_exchangeRateController.text);
      }

      final transaction = Transaction(
        id: widget.transactionToEdit?.id, // Keep the same ID if editing
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date:
            widget.transactionToEdit?.date ??
            DateTime.now()
                .millisecondsSinceEpoch, // Keep original date if editing
        tags: tags,
        type: _selectedType,
        isTemplate: _isTemplate,
        onlyBudget: onlyBudget, // Always false for visibility in account transactions
        budgetId: _selectedBudgetId,
        accountId: _selectedAccountId,
        toAccountId: _selectedType == TransactionType.transfer
            ? _toAccountId
            : null,
        exchangeRate: exchangeRate,
      );

      if (widget.transactionToEdit != null) {
        // Update existing transaction
        await context.read<TransactionProvider>().updateTransactionData(
          transaction,
        );
      } else {
        // Add new transaction
        await context.read<TransactionProvider>().addTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
