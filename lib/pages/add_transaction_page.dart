import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/entity/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

class AddTransactionPage extends StatefulWidget {
  final int? preselectedBudgetId;

  const AddTransactionPage({super.key, this.preselectedBudgetId});

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

  @override
  void initState() {
    super.initState();
    // Set the preselected budget ID if provided
    _selectedBudgetId = widget.preselectedBudgetId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Only show budget dropdown if no budget is preselected
              if (widget.preselectedBudgetId == null)
                Consumer<BudgetProvider>(
                  builder: (context, budgetProvider, child) {
                    final budgets = budgetProvider.budgets;
                    return DropdownButtonFormField<int>(
                      initialValue: _selectedBudgetId,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                        border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Template'),
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
                child: const Text('Save Transaction'),
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

      // onlyBudget is true when created from budget (preselectedBudgetId exists)
      final onlyBudget = widget.preselectedBudgetId != null;

      final transaction = Transaction(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.now().millisecondsSinceEpoch,
        tags: tags,
        type: _selectedType,
        isTemplate: _isTemplate,
        onlyBudget: onlyBudget,
        budgetId: _selectedBudgetId,
      );

      await context.read<TransactionProvider>().addTransaction(transaction);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
