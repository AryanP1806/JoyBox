// lib/games/assassin/assassin_role_reveal_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/safe_nav.dart';
import '../../theme/party_theme.dart';
import '../../widgets/party_card.dart';
import '../../widgets/party_button.dart';

import 'assassin_models.dart';
import 'assassin_play_screen.dart';

class AssassinRoleRevealScreen extends StatefulWidget {
  final AssassinGameConfig config;

  const AssassinRoleRevealScreen({super.key, required this.config});

  @override
  State<AssassinRoleRevealScreen> createState() =>
      _AssassinRoleRevealScreenState();
}

class _AssassinRoleRevealScreenState extends State<AssassinRoleRevealScreen> {
  late final List<AssassinPlayer> _players;
  int _currentIndex = 0;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _players = _generatePlayers();
  }

  List<AssassinPlayer> _generatePlayers() {
    final rand = Random();
    final names = widget.config.playerNames;
    final total = widget.config.playerCount;

    final assassinCount = widget.config.assassinCount;
    final detectiveCount = widget.config.detectiveCount;

    final allIndexes = List.generate(total, (i) => i)..shuffle(rand);

    final assassinIndexes = allIndexes.take(assassinCount).toSet();
    final detectiveIndexes = allIndexes
        .skip(assassinCount)
        .take(detectiveCount)
        .toSet();

    return List.generate(total, (i) {
      if (assassinIndexes.contains(i)) {
        return AssassinPlayer(name: names[i], role: AssassinRole.assassin);
      } else if (detectiveIndexes.contains(i)) {
        return AssassinPlayer(name: names[i], role: AssassinRole.detective);
      } else {
        return AssassinPlayer(name: names[i], role: AssassinRole.citizen);
      }
    });
  }

  void _next() {
    if (_players.isEmpty) {
      SafeNav.goHome(context);
      return;
    }

    if (_currentIndex >= _players.length - 1) {
      SafeNav.safeReplace(
        context,
        AssassinPlayScreen(players: _players, config: widget.config),
      );
    } else {
      setState(() {
        _revealed = false;
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_players.isEmpty) {
      SafeNav.goHome(context);
      return const SizedBox.shrink();
    }

    final player = _players[_currentIndex];

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Role Reveal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: _revealed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PartyCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ NAME — SAFE SIZE
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              player.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ✅ ROLE — SAFE SIZE
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _roleLabel(player.role),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _roleColor(player.role),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ✅ DESCRIPTION — NO OVERFLOW
                          Text(
                            _roleDescription(player.role),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    PartyButton(
                      text: _currentIndex == _players.length - 1
                          ? "START ROUND"
                          : "NEXT PLAYER",
                      gradient: PartyGradients.truth,
                      onTap: _next,
                    ),
                  ],
                )
              : PartyButton(
                  text: "Give phone to",
                  subText: player.name, // ✅ clean + safe
                  gradient: PartyGradients.dare,
                  onTap: () {
                    setState(() => _revealed = true);
                  },
                ),
        ),
      ),
    );
  }

  String _roleLabel(AssassinRole role) {
    switch (role) {
      case AssassinRole.assassin:
        return "ASSASSIN 😈";
      case AssassinRole.detective:
        return "DETECTIVE 🕵️";
      case AssassinRole.citizen:
        return "CIVILIAN 🧑";
    }
  }

  Color _roleColor(AssassinRole role) {
    switch (role) {
      case AssassinRole.assassin:
        return Colors.redAccent;
      case AssassinRole.detective:
        return Colors.cyanAccent;
      case AssassinRole.citizen:
        return Colors.greenAccent;
    }
  }

  String _roleDescription(AssassinRole role) {
    switch (role) {
      case AssassinRole.assassin:
        return "You are the killer.\nWink at players to eliminate them.\nIf the Detective exposes you, you lose.";
      case AssassinRole.detective:
        return "You are the Detective.\nObserve carefully.\nYou get ONLY ONE accusation.";
      case AssassinRole.citizen:
        return "You are a civilian.\nAct normal.\nSurvive and help the Detective.";
    }
  }
}
