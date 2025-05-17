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

class PracticeKeysPage extends StatefulWidget {
  final SessionConfig config;

  const PracticeKeysPage({super.key, required this.config});

  @override
  State<PracticeKeysPage> createState() => _PracticeKeysPageState();
}

class _PracticeKeysPageState extends State<PracticeKeysPage> {
  Timer? _nextQuestionTimer;

  late TimerWidget _timerWidget;
  late Note _questionNote;
  late List<NoteKey> _answerKeys;
  NoteKey? _correctKey;
  Set<NoteKey> _wrongKeys = {};

  final _timer = PracticeTimer();
  final _noteQueue = Queue<Note>();
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
    _noteQueue.addAll(_shuffled([...widget.config.notes]));
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_noteQueue.isEmpty) {
      return _addQuestions();
    }
    final questionNote = _noteQueue.removeFirst();
    // Determine the list of choices by adding keys to a set in a specific
    // order: one correct answer, selected keys with the same accidental,
    // all selected keys, and finally all keys with the same accidental if the
    // user has selected less keys than the number of choices to display.
    // Elements are only included once in the set and have a stable order.
    // Show the requested number of leading elements in random order.
    final allKeys = _shuffled(getAllKeys());
    final selectedKeys = _shuffled([...widget.config.keys]);
    bool isCorrectKey(key) => getNoteFromKey(key) == questionNote;
    final correctKey = selectedKeys.firstWhere(
      isCorrectKey,
      orElse: () => allKeys.firstWhere(isCorrectKey),
    );
    final choices = <NoteKey>{correctKey};
    bool isPreferredKey(key) => key.accidental == questionNote.accidental;
    choices.addAll(selectedKeys.where(isPreferredKey));
    choices.addAll(selectedKeys);
    if (choices.length < widget.config.numChoices) {
      choices.addAll(allKeys.where(isPreferredKey));
    }

    setState(() {
      _timerWidget = TimerWidget(
        timeSeconds: widget.config.timeLimitSeconds,
        onTimerEnd: _onTimerEnd,
      );
      _questionNote = questionNote;
      _answerKeys = _shuffled([...choices.take(widget.config.numChoices)]);
      _correctKey = null;
      _wrongKeys = {};
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

  void _handleAnswerTap(NoteKey tappedKey) {
    if (_correctKey != null) return;
    final isCorrect = getNoteFromKey(tappedKey) == _questionNote;
    Provider.of<SessionsProvider>(
      context,
      listen: false,
    ).incrementSessionStats(widget.config.id, isCorrect, _timer.takeSeconds());
    if (isCorrect) {
      setState(() => _correctKey = tappedKey);
      _nextQuestionTimer = Timer(
        const Duration(milliseconds: 500),
        () => _goToNextQuestion(),
      );
    } else {
      setState(() => _wrongKeys.add(tappedKey));
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
            // --- The Question Display ---
            Text(
              Localizations.of(context, NoteLocalizations).name(_questionNote),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 12),
            // --- Wrap of Answer Buttons ---
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                ..._answerKeys.map((choice) {
                  Color? buttonColor = getSecondaryContainerColor(context);
                  if (_correctKey == choice) {
                    buttonColor = getCorrectColor(context);
                  } else if (_wrongKeys.contains(choice)) {
                    buttonColor = getWrongColor(context);
                  }
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () => _handleAnswerTap(choice),
                      clipBehavior: Clip.hardEdge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        textStyle: const TextStyle(
                          fontSize: 32,
                          fontFamily: 'StaffClefPitches',
                        ),
                        minimumSize: const Size(100, 100),
                      ),
                      child: Text(getGlyphsFromKey(choice)),
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
