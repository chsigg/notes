import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isEditMode = false;
  Locale _locale = const Locale('en'); // Default to English
  static const _isEditModePrefKey = 'is_edit_mode';
  static const _localePrefKey = 'locale';

  bool get isEditMode => _isEditMode;

  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEditMode = prefs.getBool(_isEditModePrefKey) ?? false;
      final localeString = prefs.getString(_localePrefKey) ?? 'en';
      _locale = Locale(localeString);
      notifyListeners();
    } catch (e) {
      // Ignore errors loading preferences.
    }
  }

  void setEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
    _saveSettings();
  }

  void setLocale(Locale value) {
    _locale = value;
    notifyListeners();
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isEditModePrefKey, _isEditMode);
      await prefs.setString(_localePrefKey, _locale.languageCode);
    } catch (e) {
      // Ignore errors saving preferences.
    }
  }
}
