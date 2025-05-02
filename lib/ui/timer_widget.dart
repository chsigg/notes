import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int timeSeconds;
  final VoidCallback onTimerEnd;

  const TimerWidget({super.key, required this.timeSeconds, required this.onTimerEnd});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _timeRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.timeSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _timeRemaining <= 3 ? Colors.red : null;
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 32, color: color),
        SizedBox(width: 12),
        Text(_timeRemaining.toString(), style: TextStyle(fontSize: 24.0)),
      ],
    );
  }

  void _onTimerTick(Timer timer) {
    setState(() => _timeRemaining--);
    if (_timeRemaining <= 0) {
      _timer.cancel();
      widget.onTimerEnd();
    }
  }
}
