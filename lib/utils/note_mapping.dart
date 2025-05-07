// lib/utils/note_mapping.dart

import 'dart:collection';

import 'package:flutter/widgets.dart';

enum Clef {
  treble,
  bass;

  factory Clef.fromString(String str) {
    return {'𝄞': Clef.treble, '𝄢': Clef.bass}[str]!;
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

  factory NaturalNote.fromString(String str) {
    return NaturalNote.values.asNameMap()[str]!;
  }
}

enum Accidental {
  natural,
  sharp,
  flat;

  factory Accidental.fromString(String str) {
    return {
      '': Accidental.natural,
      '♯': Accidental.sharp,
      '♭': Accidental.flat,
    }[str]!;
  }
}

class Note {
  final NaturalNote note;
  final Accidental accidental;

  const Note(this.note, this.accidental);

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
  return [..._noteToGermanNameMap.keys];
}

List<Note> getNaturalNotes() {
  isNatural(note) => note.accidental == Accidental.natural;
  return [..._noteToGermanNameMap.keys.where(isNatural)];
}

// Returns the value of a note in integer notation.
int getIntegerFromNote(Note note) {
  return _noteToIntegerMap[note]!;
}

List<NoteKey> getAllKeys() {
  return [..._keyToGlyphsMap.keys];
}

List<NoteKey> getAllTrebleKeys() {
  isTreble(key) => key.clef == Clef.treble;
  return [..._keyToGlyphsMap.keys.where(isTreble)];
}

List<NoteKey> getAllBassKeys() {
  isBass(key) => key.clef == Clef.treble;
  return [..._keyToGlyphsMap.keys.where(isBass)];
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
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('nl'),
  ];

  final Locale locale;

  NoteLocalizations(this.locale);

  String name(Note note) {
    switch (locale.languageCode) {
      case 'de':
        return _noteToGermanNameMap[note]!;
      case 'nl':
        return _noteToGermanNameMap[note]!;
      default:
        return _noteToGermanNameMap[note]!;
    }
  }
}

class NoteLocalizationsDelegate
    extends LocalizationsDelegate<NoteLocalizations> {
  const NoteLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      NoteLocalizations.supportedLocales.contains(Locale(locale.languageCode));

  @override
  Future<NoteLocalizations> load(Locale locale) {
    return Future.value(NoteLocalizations(locale));
  }

  @override
  bool shouldReload(NoteLocalizationsDelegate old) => false;
}

// This map defines the mapping from note to the German name (String).
final _noteToGermanNameMap = LinkedHashMap<Note, String>.from({
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
});

final _noteToIntegerMap = LinkedHashMap<Note, int>.from({
  Note.fromString('C'): 0,
  Note.fromString('D'): 2,
  Note.fromString('E'): 4,
  Note.fromString('F'): 5,
  Note.fromString('G'): 7,
  Note.fromString('A'): 9,
  Note.fromString('B'): 11,

  Note.fromString('C♭'): 11,
  Note.fromString('D♭'): 1,
  Note.fromString('E♭'): 3,
  Note.fromString('F♭'): 4,
  Note.fromString('G♭'): 6,
  Note.fromString('A♭'): 8,
  Note.fromString('B♭'): 10,

  Note.fromString('C♯'): 1,
  Note.fromString('D♯'): 3,
  Note.fromString('E♯'): 5,
  Note.fromString('F♯'): 6,
  Note.fromString('G♯'): 8,
  Note.fromString('A♯'): 10,
  Note.fromString('B♯'): 0,
});

// This map defines the mapping from note key
// to the glyphs in the 'StaffClefPitches' font.
final _keyToGlyphsMap = LinkedHashMap<NoteKey, String>.from({
  NoteKey.fromString('𝄞C3'): '&=z=|',
  NoteKey.fromString('𝄞D3'): '&=x=|',
  NoteKey.fromString('𝄞E3'): '&=c=|',
  NoteKey.fromString('𝄞F3'): '&=v=|',
  NoteKey.fromString('𝄞G3'): '&=b=|',
  NoteKey.fromString('𝄞A3'): '&=n=|',
  NoteKey.fromString('𝄞B3'): '&=m=|',
  NoteKey.fromString('𝄞C4'): '&=a=|',
  NoteKey.fromString('𝄞D4'): '&=s=|',
  NoteKey.fromString('𝄞E4'): '&=d=|',
  NoteKey.fromString('𝄞F4'): '&=f=|',
  NoteKey.fromString('𝄞G4'): '&=g=|',
  NoteKey.fromString('𝄞A4'): '&=h=|',
  NoteKey.fromString('𝄞B4'): '&=j=|',
  NoteKey.fromString('𝄞C5'): '&=q=|',
  NoteKey.fromString('𝄞D5'): '&=w=|',
  NoteKey.fromString('𝄞E5'): '&=e=|',
  NoteKey.fromString('𝄞F5'): '&=r=|',
  NoteKey.fromString('𝄞G5'): '&=t=|',
  NoteKey.fromString('𝄞A5'): '&=y=|',
  NoteKey.fromString('𝄞B5'): '&=u=|',
  NoteKey.fromString('𝄞C6'): '&=1=|',
  NoteKey.fromString('𝄞D6'): '&=2=|',
  NoteKey.fromString('𝄞E6'): '&=3=|',
  NoteKey.fromString('𝄞F6'): '&=4=|',
  NoteKey.fromString('𝄞G6'): '&=5=|',
  NoteKey.fromString('𝄞A6'): '&=6=|',
  NoteKey.fromString('𝄞B6'): '&=7=|',

  NoteKey.fromString('𝄞C3♭'): '&=\u03A9=|',
  NoteKey.fromString('𝄞D3♭'): '&=\u2248=|',
  NoteKey.fromString('𝄞E3♭'): '&=\u00E7=|',
  NoteKey.fromString('𝄞F3♭'): '&=\u221A=|',
  NoteKey.fromString('𝄞G3♭'): '&=\u222B=|',
  NoteKey.fromString('𝄞A3♭'): '&=\u02DC=|',
  NoteKey.fromString('𝄞B3♭'): '&=\u00B5=|',
  NoteKey.fromString('𝄞C4♭'): '&=\u00E5=|',
  NoteKey.fromString('𝄞D4♭'): '&=\u00DF=|',
  NoteKey.fromString('𝄞E4♭'): '&=\u2202=|',
  NoteKey.fromString('𝄞F4♭'): '&=\u0192=|',
  NoteKey.fromString('𝄞G4♭'): '&=\u00A9=|',
  NoteKey.fromString('𝄞A4♭'): '&=\u02D9=|',
  NoteKey.fromString('𝄞B4♭'): '&=\u0394=|',
  NoteKey.fromString('𝄞C5♭'): '&=\u0153=|',
  NoteKey.fromString('𝄞D5♭'): '&=\u2211=|',
  NoteKey.fromString('𝄞E5♭'): '&=\u00B4=|',
  NoteKey.fromString('𝄞F5♭'): '&=\u00AE=|',
  NoteKey.fromString('𝄞G5♭'): '&=\u2020=|',
  NoteKey.fromString('𝄞A5♭'): '&=\u00A5=|',
  NoteKey.fromString('𝄞B5♭'): '&=\u00A8=|',
  NoteKey.fromString('𝄞C6♭'): '&=\u00A1=|',
  NoteKey.fromString('𝄞D6♭'): '&=\u2122=|',
  NoteKey.fromString('𝄞E6♭'): '&=\u00A3=|',
  NoteKey.fromString('𝄞F6♭'): '&=\u00A2=|',
  NoteKey.fromString('𝄞G6♭'): '&=\u221E=|',
  NoteKey.fromString('𝄞A6♭'): '&=\u00A7=|',
  NoteKey.fromString('𝄞B6♭'): '&=\u00B6=|',

  NoteKey.fromString('𝄞C3♯'): '&=Z=|',
  NoteKey.fromString('𝄞D3♯'): '&=X=|',
  NoteKey.fromString('𝄞E3♯'): '&=C=|',
  NoteKey.fromString('𝄞F3♯'): '&=V=|',
  NoteKey.fromString('𝄞G3♯'): '&=B=|',
  NoteKey.fromString('𝄞A3♯'): '&=N=|',
  NoteKey.fromString('𝄞B3♯'): '&=M=|',
  NoteKey.fromString('𝄞C4♯'): '&=A=|',
  NoteKey.fromString('𝄞D4♯'): '&=S=|',
  NoteKey.fromString('𝄞E4♯'): '&=D=|',
  NoteKey.fromString('𝄞F4♯'): '&=F=|',
  NoteKey.fromString('𝄞G4♯'): '&=G=|',
  NoteKey.fromString('𝄞A4♯'): '&=H=|',
  NoteKey.fromString('𝄞B4♯'): '&=J=|',
  NoteKey.fromString('𝄞C5♯'): '&=Q=|',
  NoteKey.fromString('𝄞D5♯'): '&=W=|',
  NoteKey.fromString('𝄞E5♯'): '&=E=|',
  NoteKey.fromString('𝄞F5♯'): '&=R=|',
  NoteKey.fromString('𝄞G5♯'): '&=T=|',
  NoteKey.fromString('𝄞A5♯'): '&=Y=|',
  NoteKey.fromString('𝄞B5♯'): '&=U=|',
  NoteKey.fromString('𝄞C6♯'): '&=!=|',
  NoteKey.fromString('𝄞D6♯'): '&=@=|',
  NoteKey.fromString('𝄞E6♯'): '&=#=|',
  NoteKey.fromString('𝄞F6♯'): '&=\$=|',
  NoteKey.fromString('𝄞G6♯'): '&=%=|',
  NoteKey.fromString('𝄞A6♯'): '&=^=|',

  NoteKey.fromString('𝄢E1'): '?=z=|',
  NoteKey.fromString('𝄢F1'): '?=x=|',
  NoteKey.fromString('𝄢G1'): '?=c=|',
  NoteKey.fromString('𝄢A1'): '?=v=|',
  NoteKey.fromString('𝄢B1'): '?=b=|',
  NoteKey.fromString('𝄢C2'): '?=n=|',
  NoteKey.fromString('𝄢D2'): '?=m=|',
  NoteKey.fromString('𝄢E2'): '?=a=|',
  NoteKey.fromString('𝄢F2'): '?=s=|',
  NoteKey.fromString('𝄢G2'): '?=d=|',
  NoteKey.fromString('𝄢A2'): '?=f=|',
  NoteKey.fromString('𝄢B2'): '?=g=|',
  NoteKey.fromString('𝄢C3'): '?=h=|',
  NoteKey.fromString('𝄢D3'): '?=j=|',
  NoteKey.fromString('𝄢E3'): '?=q=|',
  NoteKey.fromString('𝄢F3'): '?=w=|',
  NoteKey.fromString('𝄢G3'): '?=e=|',
  NoteKey.fromString('𝄢A3'): '?=r=|',
  NoteKey.fromString('𝄢B3'): '?=t=|',
  NoteKey.fromString('𝄢C4'): '?=y=|',
  NoteKey.fromString('𝄢D4'): '?=u=|',
  NoteKey.fromString('𝄢E4'): '?=1=|',
  NoteKey.fromString('𝄢F4'): '?=2=|',
  NoteKey.fromString('𝄢G4'): '?=3=|',
  NoteKey.fromString('𝄢A4'): '?=4=|',
  NoteKey.fromString('𝄢B4'): '?=5=|',
  NoteKey.fromString('𝄢C5'): '?=6=|',
  NoteKey.fromString('𝄢D5'): '?=7=|',

  NoteKey.fromString('𝄢E1♭'): '?=\u03A9=|',
  NoteKey.fromString('𝄢F1♭'): '?=\u2248=|',
  NoteKey.fromString('𝄢G1♭'): '?=\u00E7=|',
  NoteKey.fromString('𝄢A1♭'): '?=\u221A=|',
  NoteKey.fromString('𝄢B1♭'): '?=\u222B=|',
  NoteKey.fromString('𝄢C2♭'): '?=\u02DC=|',
  NoteKey.fromString('𝄢D2♭'): '?=\u00B5=|',
  NoteKey.fromString('𝄢E2♭'): '?=\u00E5=|',
  NoteKey.fromString('𝄢F2♭'): '?=\u00DF=|',
  NoteKey.fromString('𝄢G2♭'): '?=\u2202=|',
  NoteKey.fromString('𝄢A2♭'): '?=\u0192=|',
  NoteKey.fromString('𝄢B2♭'): '?=\u00A9=|',
  NoteKey.fromString('𝄢C3♭'): '?=\u02D9=|',
  NoteKey.fromString('𝄢D3♭'): '?=\u0394=|',
  NoteKey.fromString('𝄢E3♭'): '?=\u0153=|',
  NoteKey.fromString('𝄢F3♭'): '?=\u2211=|',
  NoteKey.fromString('𝄢G3♭'): '?=\u00B4=|',
  NoteKey.fromString('𝄢A3♭'): '?=\u00AE=|',
  NoteKey.fromString('𝄢B3♭'): '?=\u2020=|',
  NoteKey.fromString('𝄢C4♭'): '?=\u00A5=|',
  NoteKey.fromString('𝄢D4♭'): '?=\u00A8=|',
  NoteKey.fromString('𝄢E4♭'): '?=\u00A1=|',
  NoteKey.fromString('𝄢F4♭'): '?=\u2122=|',
  NoteKey.fromString('𝄢G4♭'): '?=\u00A3=|',
  NoteKey.fromString('𝄢A4♭'): '?=\u00A2=|',
  NoteKey.fromString('𝄢B4♭'): '?=\u221E=|',
  NoteKey.fromString('𝄢C5♭'): '?=\u00A7=|',
  NoteKey.fromString('𝄢D5♭'): '?=\u00B6=|',

  NoteKey.fromString('𝄢E1♯'): '?=Z=|',
  NoteKey.fromString('𝄢F1♯'): '?=X=|',
  NoteKey.fromString('𝄢G1♯'): '?=C=|',
  NoteKey.fromString('𝄢A1♯'): '?=V=|',
  NoteKey.fromString('𝄢B1♯'): '?=B=|',
  NoteKey.fromString('𝄢C2♯'): '?=N=|',
  NoteKey.fromString('𝄢D2♯'): '?=M=|',
  NoteKey.fromString('𝄢E2♯'): '?=A=|',
  NoteKey.fromString('𝄢F2♯'): '?=S=|',
  NoteKey.fromString('𝄢G2♯'): '?=D=|',
  NoteKey.fromString('𝄢A2♯'): '?=F=|',
  NoteKey.fromString('𝄢B2♯'): '?=G=|',
  NoteKey.fromString('𝄢C3♯'): '?=H=|',
  NoteKey.fromString('𝄢D3♯'): '?=J=|',
  NoteKey.fromString('𝄢E3♯'): '?=Q=|',
  NoteKey.fromString('𝄢F3♯'): '?=W=|',
  NoteKey.fromString('𝄢G3♯'): '?=E=|',
  NoteKey.fromString('𝄢A3♯'): '?=R=|',
  NoteKey.fromString('𝄢B3♯'): '?=T=|',
  NoteKey.fromString('𝄢C4♯'): '?=Y=|',
  NoteKey.fromString('𝄢D4♯'): '?=U=|',
  NoteKey.fromString('𝄢E4♯'): '?=!=|',
  NoteKey.fromString('𝄢F4♯'): '?&=@=|',
  NoteKey.fromString('𝄢G4♯'): '?&=#=|',
  NoteKey.fromString('𝄢A4♯'): '?=\$=|',
  NoteKey.fromString('𝄢B4♯'): '?&=%=|',
  NoteKey.fromString('𝄢C5♯'): '?&=^=|',
});
