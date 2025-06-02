import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_config.dart';
import '../providers/sessions_provider.dart';
import '../utils/colors.dart';
import '../utils/note_mapping.dart';
import 'timer_widget.dart';

class PracticeNotesPage extends StatefulWidget {
  final SessionConfig config;

  const PracticeNotesPage({super.key, required this.config});

  @override
  State<PracticeNotesPage> createState() => _PracticeNotesPageState();
}

class _PracticeNotesPageState extends State<PracticeNotesPage> {
  Timer? _nextQuestionTimer;

  int _questionsCounter = 0;
  late TimerWidget _timerWidget;
  late NoteKey _questionKey;
  late List<Note> _answerNotes;
  Note? _correctNote;
  Set<Note> _wrongNotes = {};

  final _timer = PracticeTimer();
  final _keyQueue = Queue<NoteKey>();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _addQuestions();
  }

  @override
  void dispose() {
    _timer.dispose();
    _nextQuestionTimer?.cancel();
    super.dispose();
  }

  void _addQuestions() {
    _keyQueue.addAll([...widget.config.keys]..shuffle(_random));
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (widget.config.numQuestionsPerRound > 0 &&
        _questionsCounter++ == widget.config.numQuestionsPerRound) {
      return Navigator.pop(context);
    }
    if (_keyQueue.isEmpty) {
      return _addQuestions();
    }
    final questionKey = _keyQueue.removeFirst();
    // Determine the list of choices by adding notes to a set in a specific
    // order: the correct answer, selected notes with the same accidental,
    // all selected notes, and finally all notes with the same accidental if the
    // user has selected less notes than the number of choices to display.
    // Elements are only included once in the set and have a stable order.
    // Show the requested number of leading elements in random order.
    final selectedNotes = _shuffled([...widget.config.notes]);
    final choices = <Note>{getNoteFromKey(questionKey)};
    bool isPreferredNote(note) => note.accidental == questionKey.accidental;
    choices.addAll(selectedNotes.where(isPreferredNote));
    choices.addAll(selectedNotes);
    if (choices.length < widget.config.numChoices) {
      choices.addAll(_shuffled(getAllNotes()).where(isPreferredNote));
    }

    setState(() {
      _timerWidget = TimerWidget(
        timeSeconds: widget.config.timeLimitSeconds,
        onTimerEnd: _onTimerEnd,
      );
      _questionKey = questionKey;
      _answerNotes = _shuffled([...choices.take(widget.config.numChoices)]);
      _correctNote = null;
      _wrongNotes = {};
    });
  }

  List<T> _shuffled<T>(List<T> list) {
    list.shuffle(_random);
    return list;
  }

  void _onTimerEnd() {
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    sessions.incrementSessionStats(
      widget.config.id,
      false,
      _timer.takeSeconds(),
    );
    _goToNextQuestion();
  }

  void _handleAnswerTap(Note tappedNote) {
    if (_correctNote != null) return;
    final isCorrect = tappedNote == getNoteFromKey(_questionKey);
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    sessions.incrementSessionStats(
      widget.config.id,
      isCorrect,
      _timer.takeSeconds(),
    );
    if (isCorrect) {
      setState(() => _correctNote = tappedNote);
      _nextQuestionTimer = Timer(
        const Duration(milliseconds: 500),
        () => _goToNextQuestion(),
      );
    } else {
      setState(() => _wrongNotes.add(tappedNote));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: makeAppBar(widget.config, _timerWidget),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            // --- The Question Display (Wrapped in Padding) ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                getGlyphsFromKey(_questionKey),
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
              children: [
                ..._answerNotes.map((note) {
                  Color? buttonColor = getSecondaryContainerColor(context);
                  if (_correctNote == note) {
                    buttonColor = getCorrectColor(context);
                  } else if (_wrongNotes.contains(note)) {
                    buttonColor = getWrongColor(context);
                  }
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () => _handleAnswerTap(note),
                      clipBehavior: Clip.hardEdge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        minimumSize: const Size(100, 100),
                      ),
                      child: Text(
                        Localizations.of(context, NoteLocalizations).name(note),
                        style: const TextStyle(
                          fontSize: 48,
                          height: 1.0,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
