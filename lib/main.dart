import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Screens
import 'home/party_home_screen.dart';
import 'home/login_screen.dart';
import 'home/register_screen.dart';
import 'profile/game_history_screen.dart';
import 'services/game_cache_service.dart';
import 'services/notification_permission_screen.dart';

// Games
import '../games/mr_white/mr_white_setup.dart';
import '../games/mafia/mafia_setup.dart';
import '../games/heads_up/heads_up_setup.dart';
import '../games/truth_or_dare/truth_dare_setup_screen.dart';
import '../games/assassin/assassin_setup_screen.dart';
import '../games/most_likely/most_likely_setup_screen.dart';
import '../games/viral/viral_setup_screen.dart';
import '../games/viral_or_flop/viral_or_flop_setup_screen.dart';
import '../games/quick_draw/quick_draw_setup.dart';

// FIX 1: Define the Background Handler (MUST be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're using FlutterFire, you must initialize Firebase here too
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "joybox_default_channel",
    "JoyBox Notifications",
    description: "General notifications for JoyBox",
    importance: Importance.high,
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // FIX 2: Register the background handler immediately
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Debugging Token
  FirebaseMessaging.instance.getToken().then((token) {
    print("MY_FCM_TOKEN: $token");
  });

  // ✅ START BACKGROUND SYNC
  GameCacheService().syncAllGames();

  await setupNotificationChannel();

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

      // ✅ UPDATED HOME LOGIC
      home: FutureBuilder<bool>(
        future: SharedPreferences.getInstance().then(
          (prefs) => prefs.getBool("asked_notifications") ?? false,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              backgroundColor: Color(0xFF1A1A2E),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If we haven't asked yet, show the Permission Screen
          if (snapshot.data == false) {
            return const NotificationPermissionScreen();
          }

          // If we HAVE asked (regardless of allow/deny), go to Home
          return const PartyHomeScreen();
        },
      ),

      routes: {
        "/login": (_) => const LoginScreen(),
        "/register": (_) => const RegisterScreen(),
        "/history": (context) => const GameHistoryScreen(),
        '/mrWhite': (_) => const MrWhiteSetupScreen(),
        '/mafia': (_) => const MafiaSetupScreen(),
        '/truthDare': (_) => const TruthDareSetupScreen(),
        '/headsUp': (_) => const HeadsUpSetupScreen(),
        '/assassin': (_) => const AssassinSetupScreen(),
        '/mostLikely': (_) => const MostLikelySetupScreen(),
        '/ViralOrFlop': (_) => const ViralOrFlopSetupScreen(),
        '/Viral': (_) => const ViralScreen(),
        '/quickDraw': (_) => const QuickDrawSetupScreen(),
      },
    );
  }
}
