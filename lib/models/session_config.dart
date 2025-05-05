import 'package:flutter/material.dart';

import '../utils/note_mapping.dart';
import '../utils/session_icons.dart';

enum SessionType {
  keys, // Show note, select key.
  notes, // Show key, select note.
  play, // Show note, detect pitch.
}

class SessionConfig {
  final String id;
  String title;
  IconData icon;

  SessionType type;
  List<String> keys;
  List<String> notes;
  int numChoices;
  int timeLimitSeconds;

  int practicedTests;
  int successfulTests;

  SessionConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    required this.keys,
    required this.notes,
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
      keys: List<String>.from(json['keys'] as List),
      notes: List<String>.from(json['notes'] as List),
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
      'keys': keys,
      'notes': notes,
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
    return SessionIcons.allIcons.firstWhere(
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
      orElse: () => SessionType.notes,
    );
  }

  static List<SessionConfig> getDefaultConfigs() {
    return [
      SessionConfig(
        id: '1',
        title: 'Treble Names',
        icon: SessionIcons.trebleIcon,
        type: SessionType.notes,
        keys: NoteMapping.getAllTrebleKeys(),
        notes: NoteMapping.getAllNotes(),
      ),
      SessionConfig(
        id: '2',
        title: 'Bass Names',
        icon: SessionIcons.bassIcon,
        type: SessionType.notes,
        keys: NoteMapping.getAllBaseKeys(),
        notes: NoteMapping.getAllNotes(),
      ),
      SessionConfig(
        id: '3',
        title: 'All Notes',
        icon: Icons.music_note,
        type: SessionType.keys,
        keys: NoteMapping.getAllKeys(),
        notes: NoteMapping.getAllNotes(),
      ),
      SessionConfig(
        id: '4',
        title: 'Play',
        icon: Icons.mic,
        type: SessionType.play,
        keys: [],
        notes: [...NoteMapping.getAllNotes().take(7)],
      ),
    ];
  }
}
