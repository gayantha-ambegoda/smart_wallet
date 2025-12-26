import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _currencyCodeKey = 'currency_code';
  static const String _defaultCurrencyCode = 'USD';
  static const String _languageCodeKey = 'language_code';
  static const String _defaultLanguageCode = 'en';

  // Save selected currency code
  Future<void> saveCurrencyCode(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyCodeKey, currencyCode);
  }

  // Get selected currency code
  Future<String> getCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyCodeKey) ?? _defaultCurrencyCode;
  }

  // Save selected language code
  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  // Get selected language code
  Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey) ?? _defaultLanguageCode;
  }

  // Clear all settings
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
