import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class LocaleProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _settingsService.getLanguageCode();
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    await _settingsService.saveLanguageCode(languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
