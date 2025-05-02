import 'package:flutter/material.dart';

import '../models/session_config.dart';
import '../services/session_persistence_service.dart';

class SessionConfigProvider with ChangeNotifier {
  List<SessionConfig> _configs = [];

  List<SessionConfig> get configs => _configs;

  SessionConfigProvider._();

  static Future<SessionConfigProvider> create() async {
    final provider = SessionConfigProvider._();
    await provider._loadInitialSessions();
    return provider;
  }

  Future<void> _loadInitialSessions() async {
    try {
      final loadedConfigs = await loadSessionsFromPrefs();
      if (loadedConfigs.isEmpty) {
        _configs = SessionConfig.getDefaultConfigs();
      } else {
        _configs = loadedConfigs;
      }
    } catch (e) {
      _configs = SessionConfig.getDefaultConfigs();
    }
  }

  void notifyListenersAfterLoad() {
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
    saveSessionsToPrefs(_configs);
  }

  void deleteConfig(String id) {
    _configs.removeWhere((c) => c.id == id);
    notifyListeners();
    saveSessionsToPrefs(_configs);
  }

  void incrementSessionStats(String sessionId, bool successful) {
    final index = _configs.indexWhere((c) => c.id == sessionId);
    if (index == -1) return;

    _configs[index].practicedTests += 1;
    _configs[index].successfulTests += successful ? 1 : 0;
    notifyListeners();
    saveSessionsToPrefs(_configs);
  }
}
