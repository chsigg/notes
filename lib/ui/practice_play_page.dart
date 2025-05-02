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

import '../models/session_config.dart';
import '../providers/session_config_provider.dart';
import '../utils/note_mapping.dart';
import 'timer_widget.dart';

class PracticePlayPage extends StatefulWidget {
  final SessionConfig config;

  const PracticePlayPage({super.key, required this.config});

  @override
  State<PracticePlayPage> createState() => _PracticePlayPageState();
}

class _PracticePlayPageState extends State<PracticePlayPage> {
  TimerWidget? _timerWidget;
  double? _aPitch;
  bool? _correctAnswer;
  Timer? _answerTimer;
  String? _errorMessage;

  StreamSubscription<double>? _pitchSubscription;

  late String _currentQuestion;

  final _audioRecorder = AudioRecorder();
  final _questionQueue = Queue<String>();
  final Random _random = Random();

  static const int _sampleRate = 44100;
  static const int _bufferSize = 2048;

  @override
  void initState() {
    super.initState();
    _setupAudioPipeline();
    _initializeSession();
  }

  @override
  void dispose() {
    _answerTimer?.cancel();
    _pitchSubscription?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _setupAudioPipeline() async {
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
            if (_correctAnswer != null) {
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

  void _initializeSession() {
    if (_aPitch == null) {
      _questionQueue.add('A');
    }
    _questionQueue.addAll(_shuffled([...widget.config.names]));
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_questionQueue.isEmpty) {
      return _initializeSession();
    }
    final question = _questionQueue.removeFirst();
    setState(() {
      _correctAnswer = null;
      _currentQuestion = question;
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
    Provider.of<SessionConfigProvider>(
      context,
      listen: false,
    ).incrementSessionStats(widget.config.id, false);
    _goToNextQuestion();
  }

  void _handlePitch(double pitch) {
    if (_correctAnswer != null) {
      return;
    }
    _aPitch ??= pitch;
    final semitonesFromA = log(pitch / _aPitch!) * (12 / ln2) % 12;
    final correctResult = NoteMapping.getNumSemitonesFromA(_currentQuestion);
    final isCorrect = (semitonesFromA - correctResult).abs() < 0.5;
    Provider.of<SessionConfigProvider>(
      context,
      listen: false,
    ).incrementSessionStats(widget.config.id, isCorrect);
    setState(() => _correctAnswer = isCorrect);
    _answerTimer = Timer(Duration(seconds: 1), () {
      isCorrect ? _goToNextQuestion() : setState(() => _correctAnswer = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionColor =
        _correctAnswer == null
            ? null
            : _correctAnswer!
            ? Colors.green[400]
            : Colors.red[400];
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
              style: TextStyle(fontSize: 72, color: questionColor),
            ),
            const SizedBox(height: 32),
            // --- Error Message ---
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: TextStyle(color: Colors.red[900])),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
