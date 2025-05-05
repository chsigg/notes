import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_config.dart';
import '../providers/session_config_provider.dart';
import '../utils/note_mapping.dart';
import 'timer_widget.dart';

class PracticeNotesPage extends StatefulWidget {
  final SessionConfig config;

  const PracticeNotesPage({super.key, required this.config});

  @override
  State<PracticeNotesPage> createState() => _PracticeNotesPageState();
}

class _PracticeNotesPageState extends State<PracticeNotesPage> {
  TimerWidget? _timerWidget;
  Timer? _nextQuestionTimer;

  late String _questionKey;
  late List<String> _answerNotes;
  String? _correctNote;
  Set<String> _incorrectNotes = {};

  final _keyQueue = Queue<String>();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _addQuestions();
  }

  @override
  void dispose() {
    _nextQuestionTimer?.cancel();
    super.dispose();
  }

  void _addQuestions() {
    _keyQueue.addAll(_shuffled([...widget.config.keys]));
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_keyQueue.isEmpty) {
      return _addQuestions();
    }
    final key = _keyQueue.removeFirst();
    // Determine the list of choices by adding notes to a set in a specific
    // order: the correct answer, selected notes with the same accidental,
    // all selected notes, and finally all notes with the same accidental if the
    // user has selected less notes than the number of choices to display.
    // Elements are only included once in the set and have a stable order.
    // Show the requested number of leading elements in random order.
    final selectedNotes = _shuffled([...widget.config.notes]);
    final choices = <String>{NoteMapping.getNoteFromKey(key)};
    final preferredKeys = NoteMapping.getSameAccidentalKeys(key);
    final preferredNotes = <String>{
      ...preferredKeys.map(NoteMapping.getNoteFromKey),
    };
    isPreferredNote(note) => preferredNotes.contains(note);
    choices.addAll(selectedNotes.where(isPreferredNote));
    choices.addAll(selectedNotes);
    if (choices.length < widget.config.numChoices) {
      choices.addAll(_shuffled([...preferredNotes]));
    }

    setState(() {
      _questionKey = key;
      _answerNotes = _shuffled([...choices.take(widget.config.numChoices)]);
      _correctNote = null;
      _incorrectNotes = {};
      if (widget.config.timeLimitSeconds > 0) {
        _timerWidget = TimerWidget(
          key: UniqueKey(),
          timeSeconds: widget.config.timeLimitSeconds,
          onTimerEnd: _onTimerEnd,
        );
      }
    });
  }

  List<String> _shuffled(List<String> list) {
    list.shuffle(_random);
    return list;
  }

  void _onTimerEnd() {
    Provider.of<SessionConfigProvider>(
      context,
      listen: false,
    ).incrementSessionStats(widget.config.id, false);
    _goToNextQuestion();
  }

  void _handleAnswerTap(String chosenNote) {
    if (_correctNote != null) {
      return;
    }
    final isCorrect = chosenNote == NoteMapping.getNoteFromKey(_questionKey);
    Provider.of<SessionConfigProvider>(
      context,
      listen: false,
    ).incrementSessionStats(widget.config.id, isCorrect);
    if (isCorrect) {
      setState(() => _correctNote = chosenNote);
      _nextQuestionTimer = Timer(
        const Duration(milliseconds: 500),
        () => _goToNextQuestion(),
      );
    } else {
      setState(() => _incorrectNotes.add(chosenNote));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.title),
        centerTitle: true,
        actions: [if (_timerWidget != null) _timerWidget!, SizedBox(width: 16)],
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            // --- The Question Display (Wrapped in Padding) ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                NoteMapping.getGlyphsFromKey(_questionKey),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontFamily: 'StaffClefPitches',
                ),
              ),
            ),
            const SizedBox(height: 12),
            // --- Wrap of Answer Buttons ---
            Wrap(
              alignment: WrapAlignment.center,
              children:
                  _answerNotes.map((note) {
                    Color? buttonColor;
                    if (_correctNote == note) {
                      buttonColor = Colors.green[400];
                    } else if (_incorrectNotes.contains(note)) {
                      buttonColor = Colors.red[400];
                    }
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton(
                        onPressed: () => _handleAnswerTap(note),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          textStyle: const TextStyle(fontSize: 48),
                        ),
                        child: Text(NoteMapping.getNameFromNote(note)),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
