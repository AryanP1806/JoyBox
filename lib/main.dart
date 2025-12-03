import 'package:flutter/material.dart';
// import 'home/home_screen.dart'; // use if needed
import 'home/party_home_screen.dart';
import '../games/mr_white/mr_white_setup.dart';
import '../games/mafia/mafia_setup.dart';
import '../games/heads_up/heads_up_setup.dart';
import '../games/truth_or_dare/truth_dare_setup_screen.dart';
import '../games/assassin/assassin_setup_screen.dart';
import '../games/most_likely/most_likely_setup_screen.dart';
// void main() {
//   runApp(const PartyModeratorApp());
// }

// class PartyModeratorApp extends StatelessWidget {
//   const PartyModeratorApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Party Moderator',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),
//       home: const HomeScreen(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'home/party_home_screen.dart';

void main() {
  runApp(const PartyModeratorApp());
}

class PartyModeratorApp extends StatelessWidget {
  const PartyModeratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Party Moderator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PartyHomeScreen(),
      routes: {
        // '/spy': (_) => null,
        '/mrWhite': (_) => const MrWhiteSetupScreen(),
        '/mafia': (_) => const MafiaSetupScreen(),
        '/truthDare': (_) => const TruthDareSetupScreen(),
        '/headsUp': (_) => const HeadsUpSetupScreen(),
        '/assassin': (_) => const AssassinSetupScreen(),
        '/mostLikely': (_) => const MostLikelySetupScreen(),
      },
    );
  }
}
