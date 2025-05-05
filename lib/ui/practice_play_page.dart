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
import '../utils/note_mapping.dart';
import 'timer_widget.dart';

class PracticePlayPage extends StatefulWidget {
  final SessionConfig config;

  const PracticePlayPage({super.key, required this.config});

  @override
  State<PracticePlayPage> createState() => _PracticePlayPageState();
}

class _PracticePlayPageState extends State<PracticePlayPage>
    with WidgetsBindingObserver {
  TimerWidget? _timerWidget;
  Timer _answerTimer = Timer(Duration.zero, () {});

  late String _questionNote;
  double? _aPitch;

  Widget? _statusWidget;
  String? _errorMessage;

  StreamSubscription<double>? _pitchSubscription;

  final _audioRecorder = AudioRecorder();
  final _notesQueue = Queue<String>();
  final Random _random = Random();

  static const int _sampleRate = 44100;
  static const int _bufferSize = 2048;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _startAudioRecording();
    _addQuestions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleAppLifecycleState(state);
  }

  @override
  void dispose() {
    _answerTimer.cancel();
    _stopAudioRecording().then((_) => _audioRecorder.dispose());
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _startAudioRecording() async {
    try {
      if (!await _audioRecorder.hasPermission()) {
        throw Exception('Microphone permission denied.');
      }

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
            detectPitch(chunk) async {
              final pitchDetector = PitchDetector(
                audioSampleRate: _sampleRate * 1.0,
                bufferSize: _bufferSize,
              );
              return pitchDetector.getPitchFromIntBuffer(chunk);
            }

            return Stream.fromFuture(compute(detectPitch, chunk));
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

      _pitchSubscription = pitchStream.listen(
        _handlePitch,
        onError: (error) {
          setState(() => _errorMessage = error.toString());
        },
      );
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    }
  }

  Future<void> _stopAudioRecording() async {
    await _pitchSubscription?.cancel();
    _pitchSubscription = null;
    return _audioRecorder.cancel();
  }

  Future<void> _handleAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        return _stopAudioRecording();
      case AppLifecycleState.resumed:
        return _startAudioRecording();
      default:
        return Future.value();
    }
  }

  void _addQuestions() {
    if (_aPitch == null) {
      _notesQueue.add('A');
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
      _statusWidget = null;
      _questionNote = note;
      if (_aPitch != null && widget.config.timeLimitSeconds > 0) {
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
    final sessions = Provider.of<SessionsProvider>(context, listen: false);
    sessions.incrementSessionStats(widget.config.id, false);
    _goToNextQuestion();
  }

  void _handlePitch(double pitch) {
    if (_answerTimer.isActive) {
      return;
    }
    final targetPitch = _aPitch ?? 440.0;
    final playedInteger = 9 + 12 / ln2 * log(pitch / targetPitch);
    final targetInteger = NoteMapping.getIntegerFromNote(_questionNote);
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
    sessions.incrementSessionStats(widget.config.id, isCorrect);
    final statusWidget = () {
      final color = isCorrect ? Colors.green[400] : Colors.red[400];
      if (isTuning) {
        var tune = exp(ln2 / 12 * semitonesOffset) * targetPitch;
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
              style: TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 32),
            _statusWidget ?? SizedBox(height: 32),
            const SizedBox(height: 32),
            // --- Error Message ---
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[900]),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
