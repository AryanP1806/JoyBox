import 'package:flutter/material.dart';
import '../theme/party_theme.dart';
import 'app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: PartyColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildToggle(
              title: "Sound Effects",
              value: settings.soundEnabled,
              onChanged: () {
                setState(() => settings.toggleSound());
              },
            ),

            const SizedBox(height: 20),

            _buildToggle(
              title: "Vibration",
              value: settings.vibrationEnabled,
              onChanged: () {
                setState(() => settings.toggleVibration());
              },
            ),

            const SizedBox(height: 40),

            const Divider(),

            const SizedBox(height: 16),

            const Text(
              "More settings coming soon...",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: PartyColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PartyColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            activeThumbColor: PartyColors.accentPink,
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}
