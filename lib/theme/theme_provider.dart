import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  final String _key = 'theme_mode';

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool(_key) ?? false;
    _themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_key, !isDarkMode);
  }

  void setTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }
} 