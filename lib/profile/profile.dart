import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/party_theme.dart';
import 'dart:io';
import '../auth/auth_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    if (currentUser == null) return null;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // ✅ NEW: The Safety Check Logic
  Future<void> _handleLogout() async {
    bool hasInternet = false;
    try {
      // Simple ping check to see if we have real data connection
      final result = await InternetAddress.lookup('google.com');
      hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      hasInternet = false;
    }

    if (hasInternet) {
      // We are Online: Safe to logout
      await _performLogout();
    } else {
      // We are Offline: SHOW WARNING!
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: PartyColors.card,
          title: const Text(
            "⚠️ Offline Warning",
            style: TextStyle(color: Colors.redAccent),
          ),
          content: const Text(
            "You are currently OFFLINE.\n\n"
            "If you log out now, any games played while offline will be PERMANENTLY LOST.\n\n"
            "Connect to the internet to sync your stats before logging out.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Stay logged in
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _performLogout(); // Force Logout
              },
              child: const Text(
                "Log Out Anyway",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Actual Logout Action
  Future<void> _performLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  // ... (Keep _editName method as is) ...
  Future<void> _editName(BuildContext context, String currentName) async {
    // ... your existing edit code ...
    final controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PartyColors.card,
        title: const Text(
          "Edit Username",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new name",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty && currentUser != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .update({'username': controller.text.trim()});

                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {}); // Refresh the UI
                }
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(color: PartyColors.accentPink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return _buildGuestLayout();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        // ... (Keep your existing variable setup) ...
        String username = "Party Animal";
        String email = currentUser?.email ?? "No Email";
        String initials = "P";
        int games = 0;
        int friendsCount = 0;
        int loginDays = 1;
        bool isPro = false;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: PartyColors.accentPink),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          username = data['username'] ?? "User";
          games = data['gamesPlayed'] ?? 0;
          friendsCount = data['friendsCount'] ?? 0;
          loginDays = data['loginDays'] ?? 1;
          isPro = data['isPro'] ?? false;
          if (username.isNotEmpty) initials = username[0].toUpperCase();
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _editName(context, username),
                      icon: const Icon(
                        Icons.edit,
                        color: PartyColors.accentCyan,
                      ),
                      tooltip: "Edit Profile",
                    ),
                  ],
                ),
                _ProfileHeader(
                  username: username,
                  email: email,
                  initials: initials,
                ),
                const SizedBox(height: 24),
                _StatsRow(games: games, friends: friendsCount, days: loginDays),
                const SizedBox(height: 24),
                if (!isPro) ...[
                  const _ProUpgradeCard(),
                  const SizedBox(height: 24),
                ],

                // ✅ UPDATED: Pass the new _handleLogout to the menu
                _MenuSection(
                  isGuest: false,
                  onLogout: _handleLogout, // <--- Calls our new Safety Check
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestLayout() {
    // ... (Same as previous code) ...
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              "Guest Mode",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Log in to track stats & find friends!",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PartyColors.accentPink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login').then((_) {
                  setState(() {});
                });
              },
              child: const Text(
                "Login / Register",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// -----------------------------------------------------------------------------
// HELPER WIDGETS (Must be outside the main class to be visible)
// -----------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String initials;

  const _ProfileHeader({
    required this.username,
    required this.email,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: PartyColors.card,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            fontSize: 14,
            color: PartyColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int games;
  final int friends;
  final int days;

  const _StatsRow({
    required this.games,
    required this.friends,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: PartyColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: "Games", value: games.toString()),
          _StatItem(
            label: "Friends",
            value: friends.toString(),
            color: PartyColors.accentYellow,
          ),
          _StatItem(label: "Days Active", value: "$days 🔥"),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: PartyColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProUpgradeCard extends StatelessWidget {
  const _ProUpgradeCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payments & Pro Mode coming soon!"),
            backgroundColor: PartyColors.accentPink,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4ECD), Color(0xFF2F80ED)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Get JOYBOX Pro",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Unlock all decks & remove ads.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final bool isGuest;
  final VoidCallback onLogout;

  const _MenuSection({required this.isGuest, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isGuest)
          _ProfileMenuItem(
            icon: Icons.history,
            title: "Game History",
            onTap: () => Navigator.pushNamed(context, "/history"),
          ),
        _ProfileMenuItem(
          icon: isGuest ? Icons.login : Icons.logout,
          title: isGuest ? "Log In" : "Log Out",
          isDestructive: !isGuest,
          onTap: isGuest
              ? () => Navigator.pushNamed(context, '/login')
              : onLogout,
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: PartyColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? const Color(0xFFED4337)
                    : PartyColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? const Color(0xFFED4337)
                        : PartyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: PartyColors.textSecondary.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
