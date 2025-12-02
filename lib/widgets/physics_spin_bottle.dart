import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class PhysicsSpinBottle extends StatefulWidget {
  final VoidCallback onSpinEnd;

  const PhysicsSpinBottle({super.key, required this.onSpinEnd});

  @override
  State<PhysicsSpinBottle> createState() => _PhysicsSpinBottleState();
}

class _PhysicsSpinBottleState extends State<PhysicsSpinBottle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0;
  double _velocity = 0;
  Timer? _physicsTimer;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(() {
            setState(() {
              _angle += _velocity;
            });
          });
  }

  void _startSpin() async {
    _velocity = Random().nextDouble() * 0.4 + 0.3;

    await _player.play(AssetSource("sounds/spin.mp3"));
    _controller.repeat();

    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _velocity *= 0.985; // friction

      if (_velocity < 0.002) {
        _stopSpin();
      }
    });
  }

  void _stopSpin() async {
    _physicsTimer?.cancel();
    _controller.stop();
    _player.stop();

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 120);
    }

    widget.onSpinEnd();
  }

  @override
  void dispose() {
    _controller.dispose();
    _physicsTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startSpin,
      child: Transform.rotate(
        angle: _angle,
        child: Image.asset("assets/images/bottle.png", width: 140),
      ),
    );
  }
}
