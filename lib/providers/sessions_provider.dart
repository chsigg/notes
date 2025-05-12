import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_config.dart';

class SessionsProvider with ChangeNotifier {
  List<SessionConfig> _configs = [];
  static const _configsPrefKey = 'sessions_configs_v3';

  List<SessionConfig> get configs => _configs;

  SessionsProvider() {
    _loadConfigs();
  }

  void _loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_configsPrefKey);
    if (jsonString == null || jsonString.isEmpty) {
      _configs = SessionConfig.getDefaultConfigs();
    } else {
      _configs = [
        ...(jsonDecode(jsonString) as List).map((json) {
          return SessionConfig.fromJson(json as Map<String, dynamic>);
        }),
      ];
    }
    notifyListeners();
  }

  void updateConfig(SessionConfig config) {
    final index = _configs.indexWhere((c) => c.id == config.id);
    if (index != -1) {
      _configs[index] = config; // Update existing config
    } else {
      _configs.add(config); // Add new config if not found
    }
    notifyListeners();
    _saveConfigs();
  }

  void deleteConfig(String id) {
    _configs.removeWhere((c) => c.id == id);
    notifyListeners();
    _saveConfigs();
  }

  void incrementSessionStats(String sessionId, bool successful, int seconds) {
    final index = _configs.indexWhere((c) => c.id == sessionId);
    if (index == -1) return;

    _configs[index].practicedTests += 1;
    _configs[index].successfulTests += successful ? 1 : 0;
    _configs[index].totalPracticeTime += Duration(seconds: seconds);
    notifyListeners();
    _saveConfigs();
  }

  void _saveConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = [..._configs.map((session) => session.toJson())];
    await prefs.setString(_configsPrefKey, jsonEncode(jsonList));
  }
}
