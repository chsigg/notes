import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_config.dart';
import '../providers/session_config_provider.dart';
import '../utils/note_mapping.dart';
import 'timer_widget.dart';

class PracticeKeysPage extends StatefulWidget {
  final SessionConfig config;

  const PracticeKeysPage({super.key, required this.config});

  @override
  State<PracticeKeysPage> createState() => _PracticeKeysPageState();
}

class _PracticeKeysPageState extends State<PracticeKeysPage> {
  TimerWidget? _timerWidget;
  Timer? _nextQuestionTimer;

  late String _questionNote;
  late List<String> _answerKeys;
  String? _correctKey;
  Set<String> _incorrectKeys = {};

  final _noteQueue = Queue<String>();
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
    _noteQueue.addAll(_shuffled([...widget.config.notes]));
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_noteQueue.isEmpty) {
      return _addQuestions();
    }
    final note = _noteQueue.removeFirst();
    // Determine the list of choices by adding keys to a set in a specific
    // order: one correct answer, selected keys with the same accidental,
    // all selected keys, and finally all keys with the same accidental if the
    // user has selected less keys than the number of choices to display.
    // Elements are only included once in the set and have a stable order.
    // Show the requested number of leading elements in random order.
    final allKeys = _shuffled(NoteMapping.getAllKeys());
    final selectedKeys = _shuffled([...widget.config.keys]);
    isCorrectKey(key) => NoteMapping.getNoteFromKey(key) == note;
    final choices = <String>{
      selectedKeys.firstWhere(
        isCorrectKey,
        orElse: () => allKeys.firstWhere(isCorrectKey),
      ),
    };
    final preferredKeys = <String>{
      ...NoteMapping.getSameAccidentalKeys(choices.first),
    };
    isPreferredKey(key) => preferredKeys.contains(key);
    choices.addAll(selectedKeys.where(isPreferredKey));
    choices.addAll(selectedKeys);
    if (choices.length < widget.config.numChoices) {
      choices.addAll(allKeys.where(isPreferredKey));
    }

    setState(() {
      _questionNote = note;
      _answerKeys = _shuffled([...choices.take(widget.config.numChoices)]);
      _correctKey = null;
      _incorrectKeys = {};
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

  void _handleAnswerTap(String chosenLabel) {
    if (_correctKey != null) {
      return;
    }
    final isCorrect = NoteMapping.getNoteFromKey(chosenLabel) == _questionNote;
    Provider.of<SessionConfigProvider>(
      context,
      listen: false,
    ).incrementSessionStats(widget.config.id, isCorrect);
    if (isCorrect) {
      setState(() => _correctKey = chosenLabel);
      _nextQuestionTimer = Timer(
        const Duration(milliseconds: 500),
        () => _goToNextQuestion(),
      );
    } else {
      setState(() => _incorrectKeys.add(chosenLabel));
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
            // --- The Question Display ---
            Text(
              NoteMapping.getNameFromNote(_questionNote),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 12),
            // --- Wrap of Answer Buttons ---
            Wrap(
              alignment: WrapAlignment.center,
              children:
                  _answerKeys.map((choice) {
                    Color? buttonColor;
                    if (_correctKey == choice) {
                      buttonColor = Colors.green[400];
                    } else if (_incorrectKeys.contains(choice)) {
                      buttonColor = Colors.red[400];
                    }
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton(
                        onPressed: () => _handleAnswerTap(choice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontFamily: 'StaffClefPitches',
                          ),
                        ),
                        child: Text(NoteMapping.getGlyphsFromKey(choice)),
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
