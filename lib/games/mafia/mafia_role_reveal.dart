import 'dart:math';
import 'package:flutter/material.dart';
import 'mafia_models.dart';
import 'mafia_night_phase.dart';
import 'mafia_kill_screen.dart';

class MafiaRoleRevealScreen extends StatefulWidget {
  final MafiaGameConfig config;

  const MafiaRoleRevealScreen({super.key, required this.config});

  @override
  State<MafiaRoleRevealScreen> createState() => _MafiaRoleRevealScreenState();
}

class _MafiaRoleRevealScreenState extends State<MafiaRoleRevealScreen> {
  late List<MafiaPlayer> players;
  int currentIndex = 0;
  bool revealed = false;

  @override
  void initState() {
    super.initState();
    players = _generatePlayers();
  }

  List<MafiaPlayer> _generatePlayers() {
    final rand = Random();
    final total = widget.config.players.length;

    final roles = <MafiaRole>[];

    // Add Mafia
    for (int i = 0; i < widget.config.mafiaCount; i++) {
      roles.add(MafiaRole.mafia);
    }

    // Optional roles
    if (widget.config.hasDoctor) roles.add(MafiaRole.doctor);
    if (widget.config.hasDetective) roles.add(MafiaRole.detective);

    // Fill rest with civilians
    while (roles.length < total) {
      roles.add(MafiaRole.civilian);
    }

    roles.shuffle();

    return List.generate(total, (i) {
      return MafiaPlayer(name: widget.config.players[i], role: roles[i]);
    });
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
    final player = players[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Role Reveal")),
      body: Center(
        child: revealed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    player.role.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 40),
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
            : ElevatedButton(
                onPressed: () => setState(() => revealed = true),
                child: Text("Give phone to ${player.name}"),
              ),
      ),
    );
  }
}
