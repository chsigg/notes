import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int timeSeconds;
  final VoidCallback onTimerEnd;
  final _stopwatch = Stopwatch()..start();

  TimerWidget({super.key, required this.timeSeconds, required this.onTimerEnd});

  Duration get elapsed => _stopwatch.elapsed;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late AppLifecycleListener _listener;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onInactive: () => widget._stopwatch.stop(),
      onResume: () => widget._stopwatch.start(),
    );
    if (widget.timeSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.timeSeconds <= 0) {
      return SizedBox();
    }
    final timeRemaining =
        widget.timeSeconds - widget._stopwatch.elapsed.inSeconds;
    final color = timeRemaining <= 3 ? Colors.red : null;
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 32, color: color),
        SizedBox(width: 12),
        Text(timeRemaining.toString(), style: TextStyle(fontSize: 24.0)),
      ],
    );
  }

  void _onTimerTick(Timer timer) {
    setState(() {});
    if (widget.timeSeconds <= widget._stopwatch.elapsed.inSeconds) {
      _timer!.cancel();
      _timer = null;
      widget.onTimerEnd();
    }
  }
}
