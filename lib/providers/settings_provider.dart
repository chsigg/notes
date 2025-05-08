import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isEditMode = false;
  String? _language;

  static const _isEditModePrefKey = 'is_edit_mode';
  static const _languagePrefKey = 'language';

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEditMode = prefs.getBool(_isEditModePrefKey) ?? false;
    _language = prefs.getString(_languagePrefKey);
    notifyListeners();
  }

  bool get isEditMode => _isEditMode;
  String? get language => _language;

  set isEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
    _saveSettings();
  }

  set language(String? language) {
    _language = language;
    notifyListeners();
    _saveSettings();
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isEditModePrefKey, _isEditMode);
    if (_language != null) {
      await prefs.setString(_languagePrefKey, _language!);
    } else {
      await prefs.remove(_languagePrefKey);
    }
  }
}
