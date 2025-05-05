// lib/utils/note_mapping.dart

import 'dart:collection';

class NoteMapping {
  // This map defines the mapping from note key (String, e.g. 'tC4')
  // to the glyphs in the 'StaffClefPitches' font (String).
  static final Map<String, String> _glyphsMap =
      LinkedHashMap<String, String>.from({
        'tC3': '&=z=|',
        'tD3': '&=x=|',
        'tE3': '&=c=|',
        'tF3': '&=v=|',
        'tG3': '&=b=|',
        'tA3': '&=n=|',
        'tB3': '&=m=|',
        'tC4': '&=a=|',
        'tD4': '&=s=|',
        'tE4': '&=d=|',
        'tF4': '&=f=|',
        'tG4': '&=g=|',
        'tA4': '&=h=|',
        'tB4': '&=j=|',
        'tC5': '&=q=|',
        'tD5': '&=w=|',
        'tE5': '&=e=|',
        'tF5': '&=r=|',
        'tG5': '&=t=|',
        'tA5': '&=y=|',
        'tB5': '&=u=|',
        'tC6': '&=1=|',
        'tD6': '&=2=|',
        'tE6': '&=3=|',
        'tF6': '&=4=|',
        'tG6': '&=5=|',
        'tA6': '&=6=|',
        'tB6': '&=7=|',

        'tCb3': '&=\u03A9=|',
        'tDb3': '&=\u2248=|',
        'tEb3': '&=\u00E7=|',
        'tFb3': '&=\u221A=|',
        'tGb3': '&=\u222B=|',
        'tAb3': '&=\u02DC=|',
        'tBb3': '&=\u00B5=|',
        'tCb4': '&=\u00E5=|',
        'tDb4': '&=\u00DF=|',
        'tEb4': '&=\u2202=|',
        'tFb4': '&=\u0192=|',
        'tGb4': '&=\u00A9=|',
        'tAb4': '&=\u02D9=|',
        'tBb4': '&=\u0394=|',
        'tCb5': '&=\u0153=|',
        'tDb5': '&=\u2211=|',
        'tEb5': '&=\u00B4=|',
        'tFb5': '&=\u00AE=|',
        'tGb5': '&=\u2020=|',
        'tAb5': '&=\u00A5=|',
        'tBb5': '&=\u00A8=|',
        'tCb6': '&=\u00A1=|',
        'tDb6': '&=\u2122=|',
        'tEb6': '&=\u00A3=|',
        'tFb6': '&=\u00A2=|',
        'tGb6': '&=\u221E=|',
        'tAb6': '&=\u00A7=|',
        'tBb6': '&=\u00B6=|',

        'tC#3': '&=Z=|',
        'tD#3': '&=X=|',
        'tE#3': '&=C=|',
        'tF#3': '&=V=|',
        'tG#3': '&=B=|',
        'tA#3': '&=N=|',
        'tB#3': '&=M=|',
        'tC#4': '&=A=|',
        'tD#4': '&=S=|',
        'tE#4': '&=D=|',
        'tF#4': '&=F=|',
        'tG#4': '&=G=|',
        'tA#4': '&=H=|',
        'tB#4': '&=J=|',
        'tC#5': '&=Q=|',
        'tD#5': '&=W=|',
        'tE#5': '&=E=|',
        'tF#5': '&=R=|',
        'tG#5': '&=T=|',
        'tA#5': '&=Y=|',
        'tB#5': '&=U=|',
        'tC#6': '&=!=|',
        'tD#6': '&=@=|',
        'tE#6': '&=#=|',
        'tF#6': '&=\$=|',
        'tG#6': '&=%=|',
        'tA#6': '&=^=|',

        'bE1': '?=z=|',
        'bF1': '?=x=|',
        'bG1': '?=c=|',
        'bA1': '?=v=|',
        'bB1': '?=b=|',
        'bC2': '?=n=|',
        'bD2': '?=m=|',
        'bE2': '?=a=|',
        'bF2': '?=s=|',
        'bG2': '?=d=|',
        'bA2': '?=f=|',
        'bB2': '?=g=|',
        'bC3': '?=h=|',
        'bD3': '?=j=|',
        'bE3': '?=q=|',
        'bF3': '?=w=|',
        'bG3': '?=e=|',
        'bA3': '?=r=|',
        'bB3': '?=t=|',
        'bC4': '?=y=|',
        'bD4': '?=u=|',
        'bE4': '?=1=|',
        'bF4': '?=2=|',
        'bG4': '?=3=|',
        'bA4': '?=4=|',
        'bB4': '?=5=|',
        'bC5': '?=6=|',
        'bD5': '?=7=|',

        'bEb1': '?=\u03A9=|',
        'bFb1': '?=\u2248=|',
        'bGb1': '?=\u00E7=|',
        'bAb1': '?=\u221A=|',
        'bBb1': '?=\u222B=|',
        'bCb2': '?=\u02DC=|',
        'bDb2': '?=\u00B5=|',
        'bEb2': '?=\u00E5=|',
        'bFb2': '?=\u00DF=|',
        'bGb2': '?=\u2202=|',
        'bAb2': '?=\u0192=|',
        'bBb2': '?=\u00A9=|',
        'bCb3': '?=\u02D9=|',
        'bDb3': '?=\u0394=|',
        'bEb3': '?=\u0153=|',
        'bFb3': '?=\u2211=|',
        'bGb3': '?=\u00B4=|',
        'bAb3': '?=\u00AE=|',
        'bBb3': '?=\u2020=|',
        'bCb4': '?=\u00A5=|',
        'bDb4': '?=\u00A8=|',
        'bEb4': '?=\u00A1=|',
        'bFb4': '?=\u2122=|',
        'bGb4': '?=\u00A3=|',
        'bAb4': '?=\u00A2=|',
        'bBb4': '?=\u221E=|',
        'bCb5': '?=\u00A7=|',
        'bDb5': '?=\u00B6=|',

        'bE#1': '?=Z=|',
        'bF#1': '?=X=|',
        'bG#1': '?=C=|',
        'bA#1': '?=V=|',
        'bB#1': '?=B=|',
        'bC#2': '?=N=|',
        'bD#2': '?=M=|',
        'bE#2': '?=A=|',
        'bF#2': '?=S=|',
        'bG#2': '?=D=|',
        'bA#2': '?=F=|',
        'bB#2': '?=G=|',
        'bC#3': '?=H=|',
        'bD#3': '?=J=|',
        'bE#3': '?=Q=|',
        'bF#3': '?=W=|',
        'bG#3': '?=E=|',
        'bA#3': '?=R=|',
        'bB#3': '?=T=|',
        'bC#4': '?=Y=|',
        'bD#4': '?=U=|',
        'bE#4': '?=!=|',
        'bF#4': '?=@=|',
        'bG#4': '?=#=|',
        'bA#4': '?=\$=|',
        'bB#4': '?=%=|',
        'bC#5': '?=^=|',
      });

  // This map defines the mapping from note (String, e.g. 'C')
  // to the their German name (String).
  static final Map<String, String> _noteToNameMap =
      LinkedHashMap<String, String>.from({
        'A': 'A',
        'B': 'H',
        'C': 'C',
        'D': 'D',
        'E': 'E',
        'F': 'F',
        'G': 'G',

        'Ab': 'As',
        'Bb': 'B',
        'Cb': 'Ces',
        'Db': 'Des',
        'Eb': 'Es',
        'Fb': 'Fes',
        'Gb': 'Ges',

        'A#': 'Ais',
        'B#': 'His',
        'C#': 'Cis',
        'D#': 'Dis',
        'E#': 'Eis',
        'F#': 'Fis',
        'G#': 'Gis',
      });

  // Gets the glyphs for a given note.
  static String getGlyphsFromKey(String key) {
    // Look up the character, providing a fallback if the key doesn't exist.
    return _glyphsMap[key] ?? '+';
  }

  // Gets the note for a given key.
  static String getNoteFromKey(String key) {
    assert(key.length >= 3, 'Invalid key: $key');
    return key.substring(1, key.length - 1);
  }

  static String getNameFromNote(String note) {
    return _noteToNameMap[note] ?? note;
  }

  // Returns the value of a note in integer notation.
  static int getIntegerFromNote(String name) {
    switch (_noteToNameMap.entries
        .firstWhere((entry) => entry.value == name)
        .key) {
      case 'A':
        return 9;
      case 'A#':
      case 'Bb':
        return 10;
      case 'B':
      case 'Cb':
        return 11;
      case 'B#':
      case 'C':
        return 0;
      case 'C#':
      case 'Db':
        return 1;
      case 'D':
        return 2;
      case 'D#':
      case 'Eb':
        return 3;
      case 'E':
      case 'Fb':
        return 4;
      case 'E#':
      case 'F':
        return 5;
      case 'F#':
      case 'Gb':
        return 6;
      case 'G':
        return 7;
      case 'G#':
      case 'Ab':
        return 8;
      default:
        throw Exception('Invalid note: $name');
    }
  }

  static List<String> getAllNotes() {
    return [..._noteToNameMap.keys];
  }

  static Iterable<String> getSameAccidentalKeys(String note) {
    if (note.length < 3) throw Exception('Invalid note: $note');
    getAccidental(note) => note.substring(2, note.length - 1);
    return _glyphsMap.keys.where(
      (key) => getAccidental(key) == getAccidental(note),
    );
  }

  static List<String> getAllKeys() {
    return [..._glyphsMap.keys];
  }

  static List<String> getAllTrebleKeys() {
    return [..._glyphsMap.keys.where((key) => key.startsWith('t'))];
  }

  static List<String> getAllBaseKeys() {
    return [..._glyphsMap.keys.where((key) => key.startsWith('b'))];
  }
}
