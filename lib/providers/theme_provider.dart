// يدير حالة المظهر الفاتح والداكن ويبلغ الواجهة بتغييره.
import 'package:flutter/material.dart';
import 'package:scarvs/core/constants/app_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  bool _darktheme = false;
  bool get darkTheme => _darktheme;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  void toggleTheme() {
    _darktheme = !_darktheme;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    var val = await getDarkMode();
    _darktheme = val ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await saveDarkMode(_darktheme);
  }

  static Future<bool> saveDarkMode(bool darkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(AppKeys.appMode, darkMode);
  }

  static Future<bool?> getDarkMode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final raw = prefs.get(AppKeys.appMode);
      if (raw is bool) return raw;
      if (raw is String) {
        final isDark = raw.toLowerCase() == 'true' || raw == '1';
        await prefs.remove(AppKeys.appMode);
        await prefs.setBool(AppKeys.appMode, isDark);
        return isDark;
      }
      if (raw is num) {
        final isDark = raw == 1;
        await prefs.remove(AppKeys.appMode);
        await prefs.setBool(AppKeys.appMode, isDark);
        return isDark;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
