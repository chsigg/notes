import 'package:flutter/material.dart';

import '../utils/note_mapping.dart';
import '../utils/session_icons.dart';

enum SessionType { notes, names, play }

class SessionConfig {
  final String id;
  String title;
  IconData icon;

  SessionType type;
  List<String> notes;
  List<String> names;
  int numChoices;
  int timeLimitSeconds;

  int practicedTests;
  int successfulTests;

  SessionConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    required this.notes,
    required this.names,
    this.numChoices = 3,
    this.timeLimitSeconds = 0,
    this.practicedTests = 0,
    this.successfulTests = 0,
  });

  factory SessionConfig.fromJson(Map<String, dynamic> json) {
    return SessionConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: _iconFromJsonManual(json['icon'] as Map<String, dynamic>),
      type: _sessionTypeFromJsonManual(json['type'] as String),
      notes: List<String>.from(json['notes'] as List),
      names: List<String>.from(json['names'] as List),
      numChoices: json['numChoices'] as int,
      timeLimitSeconds: json['timeLimitSeconds'] as int,
      practicedTests: json['practicedTests'] as int,
      successfulTests: json['successfulTests'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': _iconToJsonManual(icon),
      'type': _sessionTypeToJsonManual(type),
      'notes': notes,
      'names': names,
      'numChoices': numChoices,
      'timeLimitSeconds': timeLimitSeconds,
      'practicedTests': practicedTests,
      'successfulTests': successfulTests,
    };
  }

  static Map<String, dynamic> _iconToJsonManual(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
  }

  static IconData _iconFromJsonManual(Map<String, dynamic> json) {
    return SessionIcons.all_icons.firstWhere(
      (icon) =>
          icon.codePoint == json['codePoint'] &&
          icon.fontFamily == json['fontFamily'] &&
          icon.fontPackage == json['fontPackage'],
      orElse: () => Icons.music_note,
    );
  }

  static String _sessionTypeToJsonManual(SessionType type) => type.name;

  static SessionType _sessionTypeFromJsonManual(String typeName) {
    return SessionType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => SessionType.names,
    );
  }

  static List<SessionConfig> getDefaultConfigs() {
    return [
      SessionConfig(
        id: '1',
        title: 'Violin Notes',
        icon: SessionIcons.violin_icon,
        type: SessionType.names,
        notes: NoteMapping.getAllViolinNotes(),
        names: NoteMapping.getAllNames(),
      ),
      SessionConfig(
        id: '2',
        title: 'Base Notes',
        icon: SessionIcons.bass_icon,
        type: SessionType.names,
        notes: NoteMapping.getAllBaseNotes(),
        names: NoteMapping.getAllNames(),
      ),
      SessionConfig(
        id: '3',
        title: 'Note Names',
        icon: Icons.music_note,
        type: SessionType.notes,
        notes: NoteMapping.getAllNotes(),
        names: NoteMapping.getAllNames(),
      ),
    ];
  }
}
