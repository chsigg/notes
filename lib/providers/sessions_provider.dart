import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_config.dart';

class SessionsProvider with ChangeNotifier {
  final List<SessionConfig> _configs;
  static const _configsPrefKey = 'sessions_configs_v3';

  SessionsProvider._create(this._configs);

  List<SessionConfig> get configs => [..._configs];

  static Future<SessionsProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_configsPrefKey);
    final configs = <SessionConfig>[];
    if (jsonString != null) {
      configs.addAll(
        (jsonDecode(jsonString) as List).map(
          (json) => SessionConfig.fromJson(json as Map<String, dynamic>),
        ),
      );
    }
    return SessionsProvider._create(configs);
  }

  void updateConfig(SessionConfig config) {
    final index = _configs.indexWhere((c) => c.id == config.id);
    if (index != -1) {
      config.practicedTests = configs[index].practicedTests;
      config.successfulTests = configs[index].successfulTests;
      config.totalPracticeTime = configs[index].totalPracticeTime;
      _configs[index] = config; // Merge with existing config
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
