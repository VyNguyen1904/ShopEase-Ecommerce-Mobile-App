import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CountdownTimer extends StatefulWidget {
  final Duration initialDuration;

  const CountdownTimer({
    super.key,
    this.initialDuration = const Duration(hours: 2, minutes: 45, seconds: 18),
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remainingDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingDuration = widget.initialDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingDuration.inSeconds > 0) {
          _remainingDuration = _remainingDuration - const Duration(seconds: 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = _remainingDuration.inHours;
    final minutes = _remainingDuration.inMinutes.remainder(60);
    final seconds = _remainingDuration.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimeBox(_twoDigits(hours)),
        _buildDivider(),
        _buildTimeBox(_twoDigits(minutes)),
        _buildDivider(),
        _buildTimeBox(_twoDigits(seconds)),
      ],
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
