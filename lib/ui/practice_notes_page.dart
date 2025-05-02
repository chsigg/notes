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
  String? _correctAnswer;
  Set<String> _incorrectAnswers = {};
  Timer? _answerTimer;

  late String _currentQuestion;
  late List<String> _currentChoices;

  final _questionQueue = Queue<String>();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  @override
  void dispose() {
    _answerTimer?.cancel();
    super.dispose();
  }

  void _initializeSession() {
    _questionQueue.addAll(_shuffled([...widget.config.notes]));
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_questionQueue.isEmpty) {
      return _initializeSession();
    }
    final question = _questionQueue.removeFirst();

    // Determine the list of choices by adding notes to a set in a specific
    // order: one correct answer, selected notes with the same accidental,
    // all selected notes, and finally all notes with the same accidental if the
    // user has selected less notes than the number of choices to display.
    // Note that duplicates will not be included in the set. Show the requested
    // number of leading elements in random order.
    final allNotes = _shuffled(NoteMapping.getAllNotes());
    final selectedNotes = _shuffled([...widget.config.notes]);
    final isCorrectNote = (note) => NoteMapping.getNoteName(note) == question;
    final choices = <String>{
      selectedNotes.firstWhere(
        isCorrectNote,
        orElse: () => allNotes.firstWhere(isCorrectNote),
      ),
    };
    final preferredNotes = <String>{
      ...NoteMapping.getSameAccidentalNotes(choices.first),
    };
    final isPreferredNote = (note) => preferredNotes.contains(note);
    choices.addAll(selectedNotes.where(isPreferredNote));
    choices.addAll(selectedNotes);
    if (choices.length < widget.config.numChoices) {
      choices.addAll(allNotes.where(isPreferredNote));
    }

    setState(() {
      _currentQuestion = question;
      _currentChoices = _shuffled([...choices.take(widget.config.numChoices)]);
      _correctAnswer = null;
      _incorrectAnswers = {};
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
    if (_correctAnswer != null) {
      return;
    }
    final isCorrect = NoteMapping.getNoteName(chosenLabel) == _currentQuestion;
    Provider.of<SessionConfigProvider>(
      context,
      listen: false,
    ).incrementSessionStats(widget.config.id, isCorrect);
    if (isCorrect) {
      setState(() => _correctAnswer = chosenLabel);
      _answerTimer = Timer(
        const Duration(milliseconds: 500),
        () => _goToNextQuestion(),
      );
    } else {
      setState(() => _incorrectAnswers.add(chosenLabel));
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
              _currentQuestion,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 12),
            // --- Wrap of Answer Buttons ---
            Wrap(
              alignment: WrapAlignment.center,
              children:
                  _currentChoices.map((choice) {
                    Color? buttonColor;
                    if (_correctAnswer == choice) {
                      buttonColor = Colors.green[400];
                    } else if (_incorrectAnswers.contains(choice)) {
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
                        child: Text(NoteMapping.getNoteStaff(choice)),
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
