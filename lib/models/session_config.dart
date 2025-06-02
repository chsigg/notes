import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  List<NoteKey> keys;
  List<Note> notes;
  final int numChoices = 3;
  int timeLimitSeconds;
  int numQuestionsPerRound;

  int practicedTests;
  int successfulTests;
  Duration totalPracticeTime;

  SessionConfig({
    String? id,
    required this.title,
    required this.icon,
    required this.type,
    required this.keys,
    required this.notes,
    this.timeLimitSeconds = 0,
    this.numQuestionsPerRound = 0,
    this.practicedTests = 0,
    this.successfulTests = 0,
    this.totalPracticeTime = Duration.zero,
  }) : id = id ?? Uuid().v4();

  factory SessionConfig.fromJson(Map<String, dynamic> json) {
    return SessionConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: _iconFromJsonManual(json['icon'] as Map<String, dynamic>),
      type: SessionType.values.byName(json['type'] as String),
      keys: [...(json['keys'] as List).map((key) => NoteKey.fromString(key))],
      notes: [...(json['notes'] as List).map((note) => Note.fromString(note))],
      timeLimitSeconds: json['timeLimitSeconds'] as int,
      numQuestionsPerRound: json['numQuestionsPerRound'] as int? ?? 0,
      practicedTests: json['practicedTests'] as int,
      successfulTests: json['successfulTests'] as int,
      totalPracticeTime: Duration(seconds: json['totalPracticeTime'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': _iconToJsonManual(icon),
      'type': type.name,
      'keys': [...keys.map((key) => key.toString())],
      'notes': [...notes.map((key) => key.toString())],
      'timeLimitSeconds': timeLimitSeconds,
      'numQuestionsPerRound': numQuestionsPerRound,
      'practicedTests': practicedTests,
      'successfulTests': successfulTests,
      'totalPracticeTime': totalPracticeTime.inSeconds,
    };
  }

  factory SessionConfig.fromBase64(String base64) {
    final jsonString = utf8.decode(
      GZipDecoder().decodeBytes(base64Url.decode(base64)),
    );
    return SessionConfig.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  String toBase64() {
    return base64Url.encode(
      GZipEncoder().encodeBytes(utf8.encode(jsonEncode(toJson()))),
    );
  }

  static Map<String, dynamic> _iconToJsonManual(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      if (icon.fontFamily != null) 'fontFamily': icon.fontFamily,
    };
  }

  static IconData _iconFromJsonManual(Map<String, dynamic> json) {
    return SessionIcons.allIcons.firstWhere(
      (icon) =>
          icon.codePoint == json['codePoint'] &&
          icon.fontFamily == json['fontFamily'],
      orElse: () => Icons.question_mark,
    );
  }

  static List<SessionConfig> getDefaultConfigs() {
    return [
      SessionConfig(
        title: 'Treble Names',
        icon: SessionIcons.trebleIcon,
        type: SessionType.notes,
        keys: getMiddleTrebleKeys(),
        notes: getAllNotes(),
      ),
      SessionConfig(
        title: 'Bass Names',
        icon: SessionIcons.bassIcon,
        type: SessionType.notes,
        keys: getAllBassKeys(),
        notes: getAllNotes(),
      ),
      SessionConfig(
        title: 'All Notes',
        icon: Icons.star,
        type: SessionType.keys,
        keys: getAllKeys(),
        notes: getAllNotes(),
      ),
      SessionConfig(
        title: 'Play',
        icon: Icons.mic,
        type: SessionType.play,
        keys: [],
        notes: getNaturalNotes(),
      ),
    ];
  }
}
