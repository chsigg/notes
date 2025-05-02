// lib/utils/note_mapping.dart

import 'dart:collection';

class NoteMapping {
  // This map defines the mapping from standard note names (String)
  // to the string in the 'StaffClefPitches' font (String).
  static final Map<String, String> _noteToStaffMap =
      LinkedHashMap<String, String>.from({
        'vC3': '&=z=|',
        'vD3': '&=x=|',
        'vE3': '&=c=|',
        'vF3': '&=v=|',
        'vG3': '&=b=|',
        'vA3': '&=n=|',
        'vB3': '&=m=|',
        'vC4': '&=a=|',
        'vD4': '&=s=|',
        'vE4': '&=d=|',
        'vF4': '&=f=|',
        'vG4': '&=g=|',
        'vA4': '&=h=|',
        'vB4': '&=j=|',
        'vC5': '&=q=|',
        'vD5': '&=w=|',
        'vE5': '&=e=|',
        'vF5': '&=r=|',
        'vG5': '&=t=|',
        'vA5': '&=y=|',
        'vB5': '&=u=|',
        'vC6': '&=1=|',
        'vD6': '&=2=|',
        'vE6': '&=3=|',
        'vF6': '&=4=|',
        'vG6': '&=5=|',
        'vA6': '&=6=|',
        'vB6': '&=7=|',

        'vCb3': '&=\u03A9=|',
        'vDb3': '&=\u2248=|',
        'vEb3': '&=\u00E7=|',
        'vFb3': '&=\u221A=|',
        'vGb3': '&=\u222B=|',
        'vAb3': '&=\u02DC=|',
        'vBb3': '&=\u00B5=|',
        'vCb4': '&=\u00E5=|',
        'vDb4': '&=\u00DF=|',
        'vEb4': '&=\u2202=|',
        'vFb4': '&=\u0192=|',
        'vGb4': '&=\u00A9=|',
        'vAb4': '&=\u02D9=|',
        'vBb4': '&=\u0394=|',
        'vCb5': '&=\u0153=|',
        'vDb5': '&=\u2211=|',
        'vEb5': '&=\u00B4=|',
        'vFb5': '&=\u00AE=|',
        'vGb5': '&=\u2020=|',
        'vAb5': '&=\u00A5=|',
        'vBb5': '&=\u00A8=|',
        'vCb6': '&=\u00A1=|',
        'vDb6': '&=\u2122=|',
        'vEb6': '&=\u00A3=|',
        'vFb6': '&=\u00A2=|',
        'vGb6': '&=\u221E=|',
        'vAb6': '&=\u00A7=|',
        'vBb6': '&=\u00B6=|',

        'vC#3': '&=Z=|',
        'vD#3': '&=X=|',
        'vE#3': '&=C=|',
        'vF#3': '&=V=|',
        'vG#3': '&=B=|',
        'vA#3': '&=N=|',
        'vB#3': '&=M=|',
        'vC#4': '&=A=|',
        'vD#4': '&=S=|',
        'vE#4': '&=D=|',
        'vF#4': '&=F=|',
        'vG#4': '&=G=|',
        'vA#4': '&=H=|',
        'vB#4': '&=J=|',
        'vC#5': '&=Q=|',
        'vD#5': '&=W=|',
        'vE#5': '&=E=|',
        'vF#5': '&=R=|',
        'vG#5': '&=T=|',
        'vA#5': '&=Y=|',
        'vB#5': '&=U=|',
        'vC#6': '&=!=|',
        'vD#6': '&=@=|',
        'vE#6': '&=#=|',
        'vF#6': '&=\$=|',
        'vG#6': '&=%=|',
        'vA#6': '&=^=|',

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

  // This map defines the mapping from short standard note names (String)
  // to the their German name (String).
  static final Map<String, String> _noteToNameMap =
      LinkedHashMap<String, String>.from({
        'C': 'C',
        'D': 'D',
        'E': 'E',
        'F': 'F',
        'G': 'G',
        'A': 'A',
        'B': 'H',

        'Cb': 'Ces',
        'Db': 'Des',
        'Eb': 'Es',
        'Fb': 'Fes',
        'Gb': 'Ges',
        'Ab': 'As',
        'Bb': 'B',

        'C#': 'Cis',
        'D#': 'Dis',
        'E#': 'Eis',
        'F#': 'Fis',
        'G#': 'Gis',
        'A#': 'Ais',
        'B#': 'His',
      });

  // Gets the staff string for a given note.
  static String getNoteStaff(String note) {
    // Look up the character, providing a fallback if the key doesn't exist.
    return _noteToStaffMap[note] ?? '+';
  }

  // Gets the name string for a given note.
  static String getNoteName(String note) {
    if (note.length < 3) throw Exception('Invalid note: $note');
    // Look up the name, providing a fallback if the key doesn't exist.
    final key = note.substring(1, note.length - 1);
    return _noteToNameMap[key] ?? note;
  }

  static int getNumSemitonesFromA(String name) {
    switch (_noteToNameMap.entries
        .firstWhere((entry) => entry.value == name)
        .key) {
      case 'A':
        return 0;
      case 'A#':
      case 'Bb':
        return 1;
      case 'B':
      case 'Cb':
        return 2;
      case 'B#':
      case 'C':
        return 3;
      case 'C#':
      case 'Db':
        return 4;
      case 'D':
        return 5;
      case 'D#':
      case 'Eb':
        return 6;
      case 'E':
      case 'Fb':
        return 7;
      case 'E#':
      case 'F':
        return 8;
      case 'F#':
      case 'Gb':
        return 9;
      case 'G':
        return 10;
      case 'G#':
      case 'Ab':
        return 11;
      default:
        throw Exception('Invalid note: $name');
    }
  }

  static List<String> getAllNames() {
    return [..._noteToNameMap.values];
  }

  static Iterable<String> getSameAccidentalNotes(String note) {
    if (note.length < 3) throw Exception('Invalid note: $note');
    getAccidental(note) => note.substring(2, note.length - 1);
    return _noteToStaffMap.keys.where(
      (key) => getAccidental(key) == getAccidental(note),
    );
  }

  static List<String> getAllNotes() {
    return [..._noteToStaffMap.keys];
  }

  static List<String> getAllViolinNotes() {
    return [...getAllNotes().where((key) => key.startsWith('v'))];
  }

  static List<String> getAllBaseNotes() {
    return [...getAllNotes().where((key) => key.startsWith('b'))];
  }
}
