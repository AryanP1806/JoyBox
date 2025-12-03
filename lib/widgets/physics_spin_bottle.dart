import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
  late Animation<double> _rotation;
  final _audio = AudioPlayer();
  final _rand = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rotation = Tween<double>(
      begin: 0,
      end: _rand.nextDouble() * 10 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _audio.play(AssetSource("sounds/spin.mp3"));
        // if (await Vibration.hasVibrator() ?? false) {
        //   Vibration.vibrate(duration: 120);
        // }
        Vibration.hasVibrator().then((has) {
          if (has == true) Vibration.vibrate(duration: 160);
        });

        widget.onSpinEnd();
      }
    });
  }

  void spin() {
    _rotation = Tween<double>(
      begin: 0,
      end: _rand.nextDouble() * 14 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: spin,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (_, _) {
          return Transform.rotate(
            angle: _rotation.value,
            child: Image.asset(
              "assets/images/bottle.png",
              width: MediaQuery.of(context).size.width * 0.20,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audio.dispose();
    super.dispose();
  }
}
