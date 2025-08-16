// themes/theme_notifier.dart

import 'package:flutter/material.dart';
import 'app_theme.dart'; // Your normal (default) theme
import 'christmas_theme.dart';

enum AppThemeMode { normal, dark, system, christmas }

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppThemeMode _appThemeMode = AppThemeMode.normal;

  AppThemeMode get appThemeMode => _appThemeMode;
  ThemeMode get themeMode => _themeMode;

  ThemeData get usedTheme {
    switch (_appThemeMode) {
      case AppThemeMode.normal:
        return AppTheme.lightTheme;
      case AppThemeMode.christmas:
        return christmasTheme;
      case AppThemeMode.dark:
        return ThemeData.dark();
      case AppThemeMode.system:
      default:
        return AppTheme.lightTheme;
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _appThemeMode = mode;
    switch (mode) {
      case AppThemeMode.normal:
        _themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        _themeMode = ThemeMode.system;
        break;
      case AppThemeMode.christmas:
        _themeMode = ThemeMode.light; // Use light as base for custom theme
        break;
    }
    notifyListeners();
  }
}