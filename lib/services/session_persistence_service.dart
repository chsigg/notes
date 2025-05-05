import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_config.dart';

const _sessionsConfigsKey = 'sessions_configs_v2';

Future<List<SessionConfig>> loadSessionsFromPrefs() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsConfigsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) {
          try {
            return SessionConfig.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            return null;
          }
        })
        .whereType<SessionConfig>()
        .toList();
  } catch (e) {
    return [];
  }
}

Future<bool> saveSessionsToPrefs(List<SessionConfig> sessions) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((session) => session.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_sessionsConfigsKey, jsonString);
    return true;
  } catch (e) {
    return false;
  }
}
