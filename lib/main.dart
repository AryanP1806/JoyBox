// import 'package:flutter/material.dart';
// // import 'home/home_screen.dart'; // use if needed
// import 'home/party_home_screen.dart';
import '../games/mr_white/mr_white_setup.dart';
import '../games/mafia/mafia_setup.dart';
import '../games/heads_up/heads_up_setup.dart';
import '../games/truth_or_dare/truth_dare_setup_screen.dart';
import '../games/assassin/assassin_setup_screen.dart';
import '../games/most_likely/most_likely_setup_screen.dart';
import '../games/viral/viral_setup_screen.dart';
import '../games/viral_or_flop/viral_or_flop_setup_screen.dart';
// import 'home/login_screen.dart';
// import 'home/register_screen.dart';
// import 'package:firebase_core/firebase_core.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
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
//       home: const PartyHomeScreen(),
//       routes: {
//         "/login": (_) => const LoginScreen(),
//         "/register": (_) => const RegisterScreen(),

//         // '/spy': (_) => null,
//         '/mrWhite': (_) => const MrWhiteSetupScreen(),
//         '/mafia': (_) => const MafiaSetupScreen(),
//         '/truthDare': (_) => const TruthDareSetupScreen(),
//         '/headsUp': (_) => const HeadsUpSetupScreen(),
//         '/assassin': (_) => const AssassinSetupScreen(),
//         '/mostLikely': (_) => const MostLikelySetupScreen(),
//         '/ViralOrFlop': (_) => const ViralOrFlopSetupScreen(),
//         '/Viral': (_) => const ViralScreen(),
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Add this import

// Your existing imports
import 'home/party_home_screen.dart';
import 'home/login_screen.dart';
import 'home/register_screen.dart';
// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

      // REPLACE "home: const PartyHomeScreen()," WITH THIS:
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. While checking auth state, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. If user is logged in (has data), go to Home
          if (snapshot.hasData) {
            return const PartyHomeScreen();
          }

          // 3. Otherwise, go to Login
          return const LoginScreen();
        },
      ),

      routes: {
        "/login": (_) => const LoginScreen(),
        "/register": (_) => const RegisterScreen(),

        // '/spy': (_) => null,
        '/mrWhite': (_) => const MrWhiteSetupScreen(),
        '/mafia': (_) => const MafiaSetupScreen(),
        '/truthDare': (_) => const TruthDareSetupScreen(),
        '/headsUp': (_) => const HeadsUpSetupScreen(),
        '/assassin': (_) => const AssassinSetupScreen(),
        '/mostLikely': (_) => const MostLikelySetupScreen(),
        '/ViralOrFlop': (_) => const ViralOrFlopSetupScreen(),
        '/Viral': (_) => const ViralScreen(),
      },
    );
  }
}
