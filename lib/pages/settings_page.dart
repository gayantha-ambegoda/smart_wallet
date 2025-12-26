import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../database/entity/currency.dart';
import '../services/settings_service.dart';
import '../providers/locale_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService();
  String _selectedCurrencyCode = 'USD';
  String _selectedLanguageCode = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currencyCode = await _settingsService.getCurrencyCode();
    final languageCode = await _settingsService.getLanguageCode();
    setState(() {
      _selectedCurrencyCode = currencyCode;
      _selectedLanguageCode = languageCode;
      _isLoading = false;
    });
  }

  Future<void> _saveCurrency(String currencyCode) async {
    await _settingsService.saveCurrencyCode(currencyCode);
    setState(() {
      _selectedCurrencyCode = currencyCode;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.currencyUpdatedSuccessfully,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveLanguage(String languageCode) async {
    if (mounted) {
      await context.read<LocaleProvider>().setLocale(languageCode);
      setState(() {
        _selectedLanguageCode = languageCode;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.languageUpdatedSuccessfully,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.currency,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCurrencyCode,
                          decoration: InputDecoration(
                            labelText: l10n.selectCurrency,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.monetization_on),
                          ),
                          isExpanded: true,
                          items: CurrencyList.currencies.map((currency) {
                            return DropdownMenuItem<String>(
                              value: currency.code,
                              child: Row(
                                children: [
                                  Text(
                                    currency.symbol,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${currency.name} (${currency.code})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _saveCurrency(value);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.selected}: ${CurrencyList.getByCode(_selectedCurrencyCode).name} (${CurrencyList.getByCode(_selectedCurrencyCode).symbol})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.language,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedLanguageCode,
                          decoration: InputDecoration(
                            labelText: l10n.selectLanguage,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.translate),
                          ),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'en',
                              child: Text(l10n.english),
                            ),
                            DropdownMenuItem<String>(
                              value: 'fr',
                              child: Text(l10n.french),
                            ),
                            DropdownMenuItem<String>(
                              value: 'da',
                              child: Text(l10n.danish),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _saveLanguage(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
