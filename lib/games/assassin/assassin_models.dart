// lib/games/assassin/assassin_models.dart
import 'package:flutter/foundation.dart';

enum AssassinRole { assassin, detective, citizen }

@immutable
class AssassinPlayer {
  final String name;
  final AssassinRole role;
  final int score;

  const AssassinPlayer({
    required this.name,
    required this.role,
    this.score = 0,
  });

  AssassinPlayer copyWith({String? name, AssassinRole? role, int? score}) {
    return AssassinPlayer(
      name: name ?? this.name,
      role: role ?? this.role,
      score: score ?? this.score,
    );
  }
}

class AssassinGameConfig {
  final int playerCount;
  final List<String> playerNames;
  final bool backgroundMusic;

  // ✅ ROLE COUNTS
  final int assassinCount;
  final int detectiveCount;

  // ✅ TIMER SYSTEM (THIS WAS MISSING)
  final bool timerEnabled;
  final int timerSeconds;

  AssassinGameConfig({
    required this.playerCount,
    required this.playerNames,
    required this.backgroundMusic,
    required this.assassinCount,
    required this.detectiveCount,

    // ✅ TIMER
    required this.timerEnabled,
    required this.timerSeconds,
  });
}

enum AssassinWinner { civilians, assassin }
