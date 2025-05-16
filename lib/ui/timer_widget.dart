import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/colors.dart';

class PracticeTimer {
  final _stopwatch = Stopwatch()..start();
  Duration _carry = Duration.zero;
  late final AppLifecycleListener _listener;

  PracticeTimer() {
    _listener = AppLifecycleListener(
      onInactive: () => _stopwatch.stop(),
      onResume: () => _stopwatch.start(),
    );
  }

  void dispose() => _listener.dispose();

  int takeSeconds() {
    final elapsed = _stopwatch.elapsed + _carry;
    _stopwatch.reset();
    final seconds = elapsed.inSeconds;
    _carry = elapsed - Duration(seconds: seconds);
    return seconds;
  }
}

class TimerWidget extends StatefulWidget {
  final int timeSeconds;
  final VoidCallback onTimerEnd;

  TimerWidget({required this.timeSeconds, required this.onTimerEnd})
    : super(key: UniqueKey());

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  AppLifecycleListener? _listener;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeSeconds;
    if (_remainingSeconds > 0) {
      _startTimer();
      _listener = AppLifecycleListener(
        onInactive: () => _stopTimer(),
        onResume: () => _startTimer(),
      );
    }
  }

  @override
  void dispose() {
    _listener?.dispose();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timer == null) {
      return SizedBox();
    }
    final color = _remainingSeconds <= 3 ? getErrorColor(context) : null;
    return Row(
      children: [
        Text(_remainingSeconds.toString(), style: TextStyle(fontSize: 20.0)),
        SizedBox(width: 8),
        Icon(Icons.timer_outlined, color: color),
        SizedBox(width: 8),
      ],
    );
  }

  void _startTimer() =>
      _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);

  void _stopTimer() => _timer?.cancel();

  void _onTimerTick(Timer timer) {
    setState(() => --_remainingSeconds);
    if (_remainingSeconds <= 0) {
      _stopTimer();
      widget.onTimerEnd();
    }
  }
}
