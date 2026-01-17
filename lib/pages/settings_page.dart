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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionCard(
                  icon: Icons.attach_money,
                  title: l10n.currency,
                  subtitle:
                      '${l10n.selected}: ${CurrencyList.getByCode(_selectedCurrencyCode).name} (${CurrencyList.getByCode(_selectedCurrencyCode).symbol})',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrencyCode,
                    decoration: InputDecoration(
                      labelText: l10n.selectCurrency,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.monetization_on_outlined),
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
                ),
                _buildSectionCard(
                  icon: Icons.language,
                  title: l10n.language,
                  subtitle: l10n.selectLanguage,
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguageCode,
                    decoration: InputDecoration(
                      labelText: l10n.selectLanguage,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
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
                ),
              ],
            ),
    );
  }
}
