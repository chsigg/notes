import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/note_mapping.dart';

class SettingsProvider with ChangeNotifier {
  bool _isEditMode = false;
  String? _language;

  static const _isEditModePrefKey = 'is_edit_mode';
  static const _languagePrefKey = 'language';

  SettingsProvider._create(this._isEditMode, this._language);

  static Future<SettingsProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isEditMode = prefs.getBool(_isEditModePrefKey) ?? false;
    final language = prefs.getString(_languagePrefKey);
    return SettingsProvider._create(isEditMode, language);
  }

  bool get isEditMode => _isEditMode;

  String? get language => _language;

  set isEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
    _saveSettings();
  }

  set language(String? language) {
    if (language != null &&
        !NoteLocalizations.supportedLanguages.contains(language)) {
      return;
    }
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
