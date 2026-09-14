import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings: theme mode, reading font size, and code font size.
/// Stored locally with shared_preferences.
class SettingsStore extends ChangeNotifier {
  SettingsStore._();
  static final SettingsStore instance = SettingsStore._();

  static const _themeKey = 'jovexa-settings-theme';
  static const _fontKey = 'jovexa-settings-font-scale';
  static const _codeFontKey = 'jovexa-settings-code-font';

  SharedPreferences? _prefs;

  ThemeMode themeMode = ThemeMode.system;
  double fontScale = 1.0; // 0.9, 1.0, 1.1, 1.2
  double codeFontSize = 13.0; // 11 to 17

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    switch (_prefs!.getString(_themeKey)) {
      case 'dark':
        themeMode = ThemeMode.dark;
      case 'light':
        themeMode = ThemeMode.light;
      default:
        themeMode = ThemeMode.system;
    }
    fontScale = _prefs!.getDouble(_fontKey) ?? 1.0;
    codeFontSize = _prefs!.getDouble(_codeFontKey) ?? 13.0;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _prefs?.setString(_themeKey, switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    });
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    fontScale = scale;
    await _prefs?.setDouble(_fontKey, scale);
    notifyListeners();
  }

  Future<void> setCodeFontSize(double size) async {
    codeFontSize = size;
    await _prefs?.setDouble(_codeFontKey, size);
    notifyListeners();
  }
}
