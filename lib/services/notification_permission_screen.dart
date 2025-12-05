import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ✅ Direct Firebase Import
import '../theme/party_theme.dart';
import '../home/party_home_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _requestAndFinish() async {
    setState(() => _isLoading = true);

    try {
      // ✅ 1. Direct Permission Request
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('User permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print("Error requesting permission: $e");
    }

    // ✅ 2. Save Preference (Always save, even if denied, so we don't loop)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("asked_notifications", true);

    if (!mounted) return;

    // ✅ 3. Navigate Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PartyHomeScreen()),
    );
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("asked_notifications", true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PartyHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartyColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_active,
                size: 90,
                color: PartyColors.accentPink,
              ),
              const SizedBox(height: 20),
              const Text(
                "Stay in the Loop!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Get updates when new games drop, streak resets, or friends beat your score.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // ✅ Loading State handling
              if (_isLoading)
                const CircularProgressIndicator(color: PartyColors.accentPink)
              else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PartyColors.accentPink,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _requestAndFinish,
                  child: const Text(
                    "ALLOW NOTIFICATIONS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _skip,
                  child: const Text(
                    "Skip for now",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
