import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale_language';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en'); // Default to English
  final SharedPreferences prefs;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  SettingsProvider(this.prefs) {
    _loadSettings();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return false; // Assuming light mode is fallback
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadSettings() {
    // Load Theme
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load Locale
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await prefs.setInt(_themeKey, _themeMode.index);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    await prefs.setString(_localeKey, languageCode);
    notifyListeners();
  }
}
