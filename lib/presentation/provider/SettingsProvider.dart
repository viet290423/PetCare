import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _prefThemeMode = 'settings.themeMode';
  static const String _prefLocale = 'settings.localeCode';

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale; // null means follow system

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_prefThemeMode);
    final savedLocale = prefs.getString(_prefLocale);

    if (themeString != null) {
      _themeMode = _parseThemeMode(themeString);
    }
    if (savedLocale != null && savedLocale.isNotEmpty) {
      _locale = Locale(savedLocale);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, _themeMode.name);
  }

  Future<void> setLocale(Locale? newLocale) async {
    _locale = newLocale; // null to follow system
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (newLocale == null) {
      await prefs.remove(_prefLocale);
    } else {
      await prefs.setString(_prefLocale, newLocale.languageCode);
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}


