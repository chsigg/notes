// lib/utils/note_mapping.dart

import 'package:flutter/widgets.dart';

enum Clef {
  treble('𝄞'),
  bass('𝄢');

  final String glyph;

  const Clef(this.glyph);

  @override
  String toString() => glyph;

  factory Clef.fromString(String str) {
    return Clef.values.firstWhere((value) => value.glyph == str);
  }
}

enum NaturalNote {
  C,
  D,
  E,
  F,
  G,
  A,
  B;

  @override
  String toString() => name;

  factory NaturalNote.fromString(String str) {
    return NaturalNote.values.asNameMap()[str]!;
  }
}

enum Accidental {
  natural(''),
  sharp('♯'),
  flat('♭');

  final String glyph;

  const Accidental(this.glyph);

  @override
  String toString() => glyph;

  factory Accidental.fromString(String str) {
    return Accidental.values.firstWhere((value) => value.glyph == str);
  }
}

class Note {
  final NaturalNote note;
  final Accidental accidental;

  const Note(this.note, this.accidental);

  @override
  String toString() => '$note$accidental';

  factory Note.fromString(String str) {
    final chars = Characters(str);
    return Note(
      NaturalNote.fromString(chars.elementAt(0)),
      Accidental.fromString(chars.skip(1).string),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Note) {
      return note == other.note && accidental == other.accidental;
    }
    return false;
  }

  @override
  int get hashCode => note.hashCode ^ accidental.hashCode;
}

class NoteKey {
  final Clef clef;
  final NaturalNote note;
  final int octave;
  final Accidental accidental;

  const NoteKey(this.clef, this.note, this.octave, this.accidental);

  @override
  String toString() => '$clef$note$octave$accidental';

  factory NoteKey.fromString(String str) {
    final chars = Characters(str);
    return NoteKey(
      Clef.fromString(chars.elementAt(0)),
      NaturalNote.fromString(chars.elementAt(1)),
      int.parse(chars.elementAt(2)),
      Accidental.fromString(chars.skip(3).string),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is NoteKey) {
      return clef == other.clef &&
          note == other.note &&
          octave == other.octave &&
          accidental == other.accidental;
    }
    return false;
  }

  @override
  int get hashCode =>
      clef.hashCode ^ note.hashCode ^ octave.hashCode ^ accidental.hashCode;
}

List<Note> getAllNotes() {
  final notes = <Note>[];
  for (final accidental in Accidental.values) {
    for (final note in NaturalNote.values) {
      notes.add(Note(note, accidental));
    }
  }
  return notes;
}

List<Note> getNaturalNotes() {
  bool isNatural(note) => note.accidental == Accidental.natural;
  return [...getAllNotes().where(isNatural)];
}

// Returns the value of a note in integer notation.
int getIntegerFromNote(Note note) {
  return {
    Note.fromString('C'): 0,
    Note.fromString('C♯'): 1,
    Note.fromString('D♭'): 1,
    Note.fromString('D'): 2,
    Note.fromString('D♯'): 3,
    Note.fromString('E♭'): 3,
    Note.fromString('E'): 4,
    Note.fromString('F♭'): 4,
    Note.fromString('E♯'): 5,
    Note.fromString('F'): 5,
    Note.fromString('F♯'): 6,
    Note.fromString('G♭'): 6,
    Note.fromString('G'): 7,
    Note.fromString('G♯'): 8,
    Note.fromString('A♭'): 8,
    Note.fromString('A'): 9,
    Note.fromString('A♯'): 10,
    Note.fromString('B♭'): 10,
    Note.fromString('B'): 11,
    Note.fromString('C♭'): 11,
    Note.fromString('B♯'): 0,
  }[note]!;
}

List<NoteKey> getAllKeys() {
  return [..._keyToGlyphsMap.keys];
}

List<NoteKey> getMiddleTrebleKeys() {
  return [
    ...getAllKeys().where(
      (key) => key.clef == Clef.treble && [4, 5].contains(key.octave),
    ),
  ];
}

List<NoteKey> getAllBassKeys() {
  return [...getAllKeys().where((key) => key.clef == Clef.bass)];
}

// Gets the glyphs for a given note.
String getGlyphsFromKey(NoteKey key) {
  // Look up the character, providing a fallback if the key doesn't exist.
  return _keyToGlyphsMap[key] ?? '+';
}

// Gets the note for a given key.
Note getNoteFromKey(NoteKey key) {
  return Note(key.note, key.accidental);
}

class NoteLocalizations {
  static const List<String> supportedLanguages = ['de', 'en', 'nl'];
  static const LocalizationsDelegate<NoteLocalizations> delegate =
      _NoteLocalizationsDelegate();

  final Locale locale;

  NoteLocalizations(this.locale);

  String name(Note note) {
    return switch (locale.languageCode) {
      'de' =>
        {
          Note.fromString('C'): 'C',
          Note.fromString('D'): 'D',
          Note.fromString('E'): 'E',
          Note.fromString('F'): 'F',
          Note.fromString('G'): 'G',
          Note.fromString('A'): 'A',
          Note.fromString('B'): 'H',

          Note.fromString('C♭'): 'Ces',
          Note.fromString('D♭'): 'Des',
          Note.fromString('E♭'): 'Es',
          Note.fromString('F♭'): 'Fes',
          Note.fromString('G♭'): 'Ges',
          Note.fromString('A♭'): 'As',
          Note.fromString('B♭'): 'B',

          Note.fromString('C♯'): 'Cis',
          Note.fromString('D♯'): 'Dis',
          Note.fromString('E♯'): 'Eis',
          Note.fromString('F♯'): 'Fis',
          Note.fromString('G♯'): 'Gis',
          Note.fromString('A♯'): 'Ais',
          Note.fromString('B♯'): 'His',
        }[note]!,
      'nl' =>
        {
          Note.fromString('C'): 'C',
          Note.fromString('D'): 'D',
          Note.fromString('E'): 'E',
          Note.fromString('F'): 'F',
          Note.fromString('G'): 'G',
          Note.fromString('A'): 'A',
          Note.fromString('B'): 'B',

          Note.fromString('C♭'): 'Ces',
          Note.fromString('D♭'): 'Des',
          Note.fromString('E♭'): 'Es',
          Note.fromString('F♭'): 'Fes',
          Note.fromString('G♭'): 'Ges',
          Note.fromString('A♭'): 'As',
          Note.fromString('B♭'): 'Bes',

          Note.fromString('C♯'): 'Cis',
          Note.fromString('D♯'): 'Dis',
          Note.fromString('E♯'): 'Eis',
          Note.fromString('F♯'): 'Fis',
          Note.fromString('G♯'): 'Gis',
          Note.fromString('A♯'): 'Ais',
          Note.fromString('B♯'): 'Bis',
        }[note]!,
      _ => '$note',
    };
  }
}

class _NoteLocalizationsDelegate
    extends LocalizationsDelegate<NoteLocalizations> {
  const _NoteLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      NoteLocalizations.supportedLanguages.contains(locale.languageCode);

  @override
  Future<NoteLocalizations> load(Locale locale) {
    return Future.value(NoteLocalizations(locale));
  }

  @override
  bool shouldReload(_NoteLocalizationsDelegate old) => false;
}

// This map defines the mapping from note key
// to the glyphs in the 'StaffClefPitches' font.
final _keyToGlyphsMap = () {
  final naturalGlyphs = [...'zxcvbnmasdfghjqwertyu1234567'.characters].asMap();
  final flatGlyphs = [...'Ω≈ç√∫˜µåß∂ƒ©˙Δœ∑´®†¥¨¡™£¢∞§¶'.characters].asMap();
  final sharpGlyphs = [...'ZXCVBNMASDFGHJQWERTYU!@#\$%^'.characters].asMap();

  MapEntry<NoteKey, String> getEntry(clef, index, accidental, glyph) {
    final note = NaturalNote.values[index % 7];
    final key = NoteKey(clef, note, index ~/ 7, accidental);
    return MapEntry(key, glyph);
  }

  MapEntry<NoteKey, String> getTrebleEntry(index, accidental, glyph) =>
      getEntry(Clef.treble, index + 21, accidental, '&=$glyph=|');
  MapEntry<NoteKey, String> getBassEntry(index, accidental, glyph) =>
      getEntry(Clef.bass, index + 9, accidental, '?=$glyph=|');

  return <NoteKey, String>{
    ...naturalGlyphs.map(
      (index, glyph) => getTrebleEntry(index, Accidental.natural, glyph),
    ),
    ...flatGlyphs.map(
      (index, glyph) => getTrebleEntry(index, Accidental.flat, glyph),
    ),
    ...sharpGlyphs.map(
      (index, glyph) => getTrebleEntry(index, Accidental.sharp, glyph),
    ),
    ...naturalGlyphs.map(
      (index, glyph) => getBassEntry(index, Accidental.natural, glyph),
    ),
    ...flatGlyphs.map(
      (index, glyph) => getBassEntry(index, Accidental.flat, glyph),
    ),
    ...sharpGlyphs.map(
      (index, glyph) => getBassEntry(index, Accidental.sharp, glyph),
    ),
  };
}();
