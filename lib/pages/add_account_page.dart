import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isEditing ? l10n.editAccount : l10n.addAccount,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAccount(),
                  tooltip: l10n.deleteAccount,
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
                decoration: InputDecoration(
                  labelText: l10n.accountName,
                  border: const OutlineInputBorder(),
                  helperText: l10n.exampleCheckingAccount,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAccountName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  labelText: l10n.bankName,
                  border: const OutlineInputBorder(),
                  helperText: l10n.exampleBankName,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterBankName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrencyCode,
                decoration: InputDecoration(
                  labelText: l10n.currency,
                  border: const OutlineInputBorder(),
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
                  labelText: l10n.initialBalance,
                  border: const OutlineInputBorder(),
                  prefixText: CurrencyList.getByCode(
                    _selectedCurrencyCode,
                  ).symbol,
                  helperText: l10n.currentBalanceDescription,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterInitialBalance;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.setAsPrimaryAccount),
                subtitle: Text(
                  l10n.primaryAccountDescription,
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
                child: Text(isEditing ? l10n.updateAccount : l10n.saveAccount),
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Text(
            l10n.deleteAccountConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.delete),
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
