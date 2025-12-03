import 'package:flutter/material.dart';

class PulseTimerText extends StatefulWidget {
  final String text;
  final Color color;

  const PulseTimerText({super.key, required this.text, required this.color});

  @override
  State<PulseTimerText> createState() => _PulseTimerTextState();
}

class _PulseTimerTextState extends State<PulseTimerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Text(
        widget.text,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: widget.color,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
