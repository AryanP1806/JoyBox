import 'dart:math';
import 'package:flutter/material.dart';

import 'mafia_models.dart';
import 'mafia_kill_screen.dart';

class MafiaRoleRevealScreen extends StatefulWidget {
  final MafiaGameConfig config;

  const MafiaRoleRevealScreen({super.key, required this.config});

  @override
  State<MafiaRoleRevealScreen> createState() => _MafiaRoleRevealScreenState();
}

class _MafiaRoleRevealScreenState extends State<MafiaRoleRevealScreen>
    with SingleTickerProviderStateMixin {
  late List<MafiaPlayer> players;
  int currentIndex = 0;
  bool revealed = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    players = _generatePlayers();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _flipController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  List<MafiaPlayer> _generatePlayers() {
    final rand = Random();
    final total = widget.config.players.length;

    final roles = <MafiaRole>[];

    for (int i = 0; i < widget.config.mafiaCount; i++) {
      roles.add(MafiaRole.mafia);
    }

    if (widget.config.hasDoctor) roles.add(MafiaRole.doctor);
    if (widget.config.hasDetective) roles.add(MafiaRole.detective);

    while (roles.length < total) {
      roles.add(MafiaRole.civilian);
    }

    roles.shuffle(rand);

    return List.generate(total, (i) {
      return MafiaPlayer(name: widget.config.players[i], role: roles[i]);
    });
  }

  MafiaPlayer get player => players[currentIndex];

  Color _roleColor(MafiaRole role) {
    switch (role) {
      case MafiaRole.mafia:
        return Colors.redAccent;
      case MafiaRole.doctor:
        return Colors.greenAccent;
      case MafiaRole.detective:
        return Colors.cyanAccent;
      default:
        return Colors.white;
    }
  }

  String _roleEmoji(MafiaRole role) {
    switch (role) {
      case MafiaRole.mafia:
        return "🔫";
      case MafiaRole.doctor:
        return "🩺";
      case MafiaRole.detective:
        return "🕵️";
      default:
        return "🙂";
    }
  }

  void _reveal() {
    setState(() => revealed = true);
    _flipController.forward(from: 0);
  }

  void _next() {
    if (currentIndex >= players.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MafiaKillScreen(players: players, config: widget.config),
        ),
      );
    } else {
      setState(() {
        revealed = false;
        currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = player;

    return Scaffold(
      appBar: AppBar(title: const Text("Role Reveal")),
      body: Center(
        child: revealed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ✅ FLIP ANIMATION
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (_, child) {
                      final angle = _flipAnimation.value * pi;
                      final isBack = angle > pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(pi),
                                child: child,
                              )
                            : child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          _roleEmoji(p.role),
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.role.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: _roleColor(p.role),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      currentIndex == players.length - 1
                          ? "Start Night"
                          : "Next Player",
                    ),
                  ),
                ],
              )
            : GestureDetector(
                onTap: _reveal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    "Give phone to ${player.name}\nTAP TO REVEAL",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
