class AppUser {
  final String uid;
  final String email;
  final String name;
  final String username;
  final int games;
  final int wins;
  final int streak;
  final bool isPro;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
    required this.games,
    required this.wins,
    required this.streak,
    required this.isPro,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'],
      name: data['name'],
      username: data['username'],
      games: data['games'],
      wins: data['wins'],
      streak: data['streak'],
      isPro: data['isPro'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "username": username,
      "games": games,
      "wins": wins,
      "streak": streak,
      "isPro": isPro,
    };
  }
}
