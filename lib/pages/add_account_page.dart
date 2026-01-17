import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/entity/account.dart';
import '../database/entity/currency.dart';
import '../providers/account_provider.dart';
import '../l10n/app_localizations.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isEditing ? l10n.editAccount : l10n.addAccount,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
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
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  label: l10n.accountName,
                  helper: l10n.exampleCheckingAccount,
                  prefixIcon: Icons.credit_card,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAccountName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankNameController,
                decoration: _inputDecoration(
                  label: l10n.bankName,
                  helper: l10n.exampleBankName,
                  prefixIcon: Icons.account_balance,
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
                value: _selectedCurrencyCode,
                decoration: _inputDecoration(
                  label: '',
                  prefixIcon: Icons.monetization_on_outlined,
                ),
                items: CurrencyList.currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency.code,
                    child: Text('${currency.code} - ${currency.name}'),
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
                decoration: _inputDecoration(
                  label: l10n.initialBalance,
                  helper: l10n.currentBalanceDescription,
                  prefixText: CurrencyList.getByCode(
                    _selectedCurrencyCode,
                  ).symbol,
                  prefixIcon: Icons.savings_outlined,
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
              _buildSection(
                title: l10n.primary,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.setAsPrimaryAccount),
                    subtitle: Text(l10n.primaryAccountDescription),
                    value: _isPrimary,
                    activeColor: Colors.black,
                    activeTrackColor: Colors.black.withOpacity(0.4),
                    onChanged: (value) {
                      setState(() {
                        _isPrimary = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAccount,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.brightness == Brightness.light
                        ? Colors.black
                        : theme.colorScheme.primary,
                    foregroundColor: theme.brightness == Brightness.light
                        ? Colors.white
                        : theme.colorScheme.onPrimary,
                    elevation: 1,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isEditing ? Icons.check_circle : Icons.save_alt),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? l10n.updateAccount : l10n.saveAccount,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? helper,
    IconData? prefixIcon,
    String? prefixText,
  }) {
    // final theme = Theme.of(context);
    return InputDecoration(
      labelText: label.isEmpty ? null : label,
      helperText: helper,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          content: Text(l10n.deleteAccountConfirmation),
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
