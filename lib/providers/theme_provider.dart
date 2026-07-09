import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

enum AppThemeMode { green, blue, pink }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.green;
  static const String _themeKey = 'selected_theme';

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeMode get themeMode => _themeMode;

  ThemeData get currentTheme {
    switch (_themeMode) {
      case AppThemeMode.blue:
        return AppTheme.blueTheme;
      case AppThemeMode.pink:
        return AppTheme.pinkTheme;
      case AppThemeMode.green:
        return AppTheme.lightTheme;
    }
  }

  void setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = AppThemeMode.values[themeIndex];
    notifyListeners();
  }
}
