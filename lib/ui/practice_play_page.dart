import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/session_config.dart';
import '../providers/sessions_provider.dart';
import '../utils/colors.dart';
import '../utils/note_mapping.dart';
import 'timer_widget.dart';

class PracticePlayPage extends StatefulWidget {
  final SessionConfig config;

  const PracticePlayPage({super.key, required this.config});

  @override
  State<PracticePlayPage> createState() => _PracticePlayPageState();
}

class _PracticePlayPageState extends State<PracticePlayPage> {
  Timer _answerTimer = Timer(Duration.zero, () {});

  late TimerWidget _timerWidget;
  late Note _questionNote;
  double? _aPitch;

  Widget? _statusWidget;
  Widget? _errorWidget;

  StreamSubscription<double>? _pitchSubscription;
  AppLifecycleListener? _listener;

  final _timer = PracticeTimer();
  final _audioRecorder = AudioRecorder();
  final _notesQueue = Queue<Note>();
  final Random _random = Random();

  static const int _sampleRate = 44100;
  static const int _bufferSize = 2048;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _addQuestions();
    _initAudioRecording();
  }

  @override
  void dispose() {
    _timer.dispose();
    _answerTimer.cancel();
    _listener?.dispose();
    _stopAudioRecording().then((_) => _audioRecorder.dispose());
    WakelockPlus.disable();
    super.dispose();
  }

  void _initAudioRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      return setState(() {
        _errorWidget = Icon(
          Icons.mic_off,
          color: getErrorColor(context),
          size: 48,
        );
      });
    }
    // Note: hasPermission() triggers an inactive/resumed state change.
    _listener = AppLifecycleListener(
      onInactive: () => _stopAudioRecording(),
      onResume: () => _startAudioRecording(),
    );
    _startAudioRecording();
  }

  void _startAudioRecording() async {
    await _stopAudioRecording();

    final recordStream = await _audioRecorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        autoGain: true,
        noiseSuppress: true,
      ),
    );

    final buffer = BytesBuilder();
    final resultWindow = <double>[];
    final pitchStream = recordStream
        .expand((data) {
          buffer.add(data);
          final chunks = <Uint8List>[];
          var bytes = buffer.takeBytes();
          const chunkSize = _bufferSize /* pcm16bits/UInt8: */ * 2;
          while (bytes.length >= chunkSize) {
            chunks.add(bytes.sublist(0, chunkSize));
            bytes = bytes.sublist(chunkSize);
          }
          buffer.add(bytes);
          return chunks;
        })
        .exhaustMap((chunk) {
          if (_answerTimer.isActive) {
            return Stream.empty();
          }
          return Stream.fromFuture(
            compute((chunk) async {
              final pitchDetector = PitchDetector(
                audioSampleRate: _sampleRate * 1.0,
                bufferSize: _bufferSize,
              );
              return pitchDetector.getPitchFromIntBuffer(chunk);
            }, chunk),
          );
        })
        .expand((result) {
          if (result.probability < 0.5) {
            resultWindow.clear();
            return <double>[];
          }
          resultWindow.add(result.pitch);
          if (resultWindow.length < 4) {
            return <double>[];
          }
          final product = resultWindow.reduce((a, b) => a * b);
          final geomean = pow(product, 1.0 / resultWindow.length) as double;
          final areAllWithinOneSemitoneOfGeomean = resultWindow.every(
            (pitch) => log(pitch / geomean).abs() * 12 <= ln2,
          );
          resultWindow.clear();
          return [if (areAllWithinOneSemitoneOfGeomean) geomean];
        });
    _pitchSubscription = pitchStream.listen(_handlePitch);
  }

  Future<void> _stopAudioRecording() async {
    await _pitchSubscription?.cancel();
    _pitchSubscription = null;
    return _audioRecorder.cancel();
  }

  void _addQuestions() {
    if (_aPitch == null) {
      _notesQueue.add(Note(NaturalNote.A, Accidental.natural));
    }
    _notesQueue.addAll(_shuffled([...widget.config.notes]));
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_notesQueue.isEmpty) {
      return _addQuestions();
    }
    final note = _notesQueue.removeFirst();
    setState(() {
      _timerWidget = TimerWidget(
        timeSeconds: _aPitch != null ? widget.config.timeLimitSeconds : 0,
        onTimerEnd: _onTimerEnd,
      );
      _questionNote = note;
      _statusWidget = null;
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

  void _handlePitch(double pitch) {
    if (_answerTimer.isActive) return;
    final targetPitch = _aPitch ?? 440.0;
    final playedInteger = 9 + 12 / ln2 * log(pitch / targetPitch);
    final targetInteger = getIntegerFromNote(_questionNote);
    var semitonesOffset = playedInteger % 12 - targetInteger;
    if (semitonesOffset > 6) {
      semitonesOffset -= 12;
    }
    final isTuning = _aPitch == null;
    final isCorrect = semitonesOffset.abs() < (isTuning ? 2 : 0.5);
    if (isCorrect) {
      _aPitch ??= pitch;
    }
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    sessions.incrementSessionStats(
      widget.config.id,
      isCorrect,
      _timer.takeSeconds(),
    );
    final statusWidget = () {
      final color =
          isCorrect ? getCorrectColor(context) : getWrongColor(context);
      if (isTuning) {
        final tune = exp(ln2 / 12 * semitonesOffset) * targetPitch;
        return SizedBox(
          height: 32,
          child: Text(
            '${tune.toStringAsFixed(0)} Hz',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: color),
          ),
        );
      }
      return Icon(
        isCorrect
            ? Icons.check
            : semitonesOffset < 0
            ? Icons.north
            : Icons.south,
        color: color,
        size: 32,
      );
    }();
    setState(() => _statusWidget = statusWidget);
    _answerTimer = Timer(Duration(seconds: 1), () {
      if (isCorrect) _goToNextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.title),
        centerTitle: true,
        actions: [_timerWidget],
      ),
      body: Center(
        child:
            _errorWidget ??
            ListView(
              shrinkWrap: true,
              children: [
                // --- The Question Display ---
                Text(
                  Localizations.of(
                    context,
                    NoteLocalizations,
                  ).name(_questionNote),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 32),
                _statusWidget ?? SizedBox(height: 32),
                const SizedBox(height: 32),
              ],
            ),
      ),
    );
  }
}
