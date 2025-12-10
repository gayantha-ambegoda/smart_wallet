import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/entity/account.dart';
import '../database/entity/currency.dart';
import '../providers/account_provider.dart';

class AddAccountPage extends StatefulWidget {
  final Account? accountToEdit;

  const AddAccountPage({super.key, this.accountToEdit});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  String _selectedCurrencyCode = 'USD';
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    // If editing an existing account, pre-fill the form
    if (widget.accountToEdit != null) {
      final account = widget.accountToEdit!;
      _nameController.text = account.name;
      _bankNameController.text = account.bankName;
      _initialBalanceController.text = account.initialBalance.toString();
      _selectedCurrencyCode = account.currencyCode;
      _isPrimary = account.isPrimary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accountToEdit != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Account' : 'Add Account',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAccount(),
                  tooltip: 'Delete Account',
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                  helperText: 'e.g., Checking Account, Savings',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                  helperText: 'e.g., Bank of America, Chase',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrencyCode,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: CurrencyList.currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency.code,
                    child: Text(
                      '${currency.symbol} ${currency.code} - ${currency.name}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrencyCode = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialBalanceController,
                decoration: InputDecoration(
                  labelText: 'Initial Balance',
                  border: const OutlineInputBorder(),
                  prefixText: CurrencyList.getByCode(
                    _selectedCurrencyCode,
                  ).symbol,
                  helperText: 'Current balance in this account',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an initial balance';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Set as Primary Account'),
                subtitle: const Text(
                  'The primary account is shown by default on the dashboard',
                ),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() {
                    _isPrimary = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAccount,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(isEditing ? 'Update Account' : 'Save Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.accountToEdit?.id,
        name: _nameController.text,
        bankName: _bankNameController.text,
        currencyCode: _selectedCurrencyCode,
        initialBalance: double.parse(_initialBalanceController.text),
        isPrimary: _isPrimary,
      );

      if (widget.accountToEdit != null) {
        await context.read<AccountProvider>().updateAccountData(account);
      } else {
        await context.read<AccountProvider>().addAccount(account);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete this account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<AccountProvider>().removeAccount(
        widget.accountToEdit!,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
