enum MafiaRole { mafia, doctor, detective, civilian }

class MafiaPlayer {
  final String name;
  MafiaRole role;
  bool isAlive;
  int score;

  MafiaPlayer({
    required this.name,
    required this.role,
    this.isAlive = true,
    this.score = 0,
  });
}

class MafiaGameConfig {
  final List<String> players;
  final int mafiaCount;
  final bool hasDoctor;
  final bool hasDetective;
  final bool secretVoting;
  final bool timerEnabled;
  final int timerSeconds;

  MafiaGameConfig({
    required this.players,
    required this.mafiaCount,
    required this.hasDoctor,
    required this.hasDetective,
    required this.secretVoting,
    required this.timerEnabled,
    required this.timerSeconds,
  });
}
