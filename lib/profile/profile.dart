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

  // Safety Check Logic
  Future<void> _handleLogout() async {
    bool hasInternet = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      hasInternet = false;
    }

    if (hasInternet) {
      await _performLogout();
    } else {
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
            "You are currently OFFLINE.\n\nIf you log out now, any games played while offline will be PERMANENTLY LOST.\n\nConnect to the internet to sync your stats before logging out.",
            style: TextStyle(color: Colors.white),
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
                Navigator.pop(context);
                await _performLogout();
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

  Future<void> _performLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  Future<void> _editName(BuildContext context, String currentName) async {
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
                // Update username AND searchKey for searching
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .update({
                      'username': controller.text.trim(),
                      'searchKey': controller.text.trim().toLowerCase(),
                    });
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {});
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

  // ✅ UPDATED: Friends Manager Popup
  void _showFriendsManager() {
    showModalBottomSheet(
      context: context,
      backgroundColor: PartyColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _FriendsBottomSheet(),
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
        String username = "Party Animal";
        String email = currentUser?.email ?? "No Email";
        String initials = "P";
        int games = 0;
        int wins = 0;
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
          wins = data['wins'] ?? 0;
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

                _StatsRow(games: games, wins: wins, streak: loginDays),

                const SizedBox(height: 24),

                // ✅ FRIEND COUNT DISPLAY
                GestureDetector(
                  onTap: _showFriendsManager,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: PartyColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: PartyColors.accentCyan,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "$friendsCount Friends",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Show request badge if needed (can implement listener later)
                            const Text(
                              "Manage",
                              style: TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                if (!isPro) ...[
                  const _ProUpgradeCard(),
                  const SizedBox(height: 24),
                ],

                _MenuSection(
                  isGuest: false,
                  onManageFriends: _showFriendsManager,
                  onLogout: _handleLogout,
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
// ✅ NEW: TABBED FRIENDS BOTTOM SHEET
// -----------------------------------------------------------------------------
class _FriendsBottomSheet extends StatelessWidget {
  const _FriendsBottomSheet();

  @override
  Widget build(BuildContext context) {
    // 80% Height
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.80,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const TabBar(
              indicatorColor: PartyColors.accentPink,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              tabs: [
                Tab(text: "Friends"),
                Tab(text: "Requests"),
                Tab(text: "Search"),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _FriendsListTab(),
                  _RequestsListTab(),
                  _SearchUsersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. FRIENDS LIST TAB
class _FriendsListTab extends StatelessWidget {
  const _FriendsListTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: AuthService().getFriendsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(color: PartyColors.accentPink),
          );
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No friends yet.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.white10,
                child: Text(
                  data['username'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                data['username'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                data['email'] ?? "",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                onPressed: () => AuthService().removeFriend(docs[i].id),
              ),
            );
          },
        );
      },
    );
  }
}

// 2. REQUESTS TAB
class _RequestsListTab extends StatelessWidget {
  const _RequestsListTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: AuthService().getRequestsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(color: PartyColors.accentPink),
          );
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No pending requests.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Card(
              color: Colors.white10,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  data['username'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Wants to be friends",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () =>
                          AuthService().rejectFriendRequest(docs[i].id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.greenAccent),
                      onPressed: () => AuthService().acceptFriendRequest(
                        docs[i].id,
                        data['username'],
                        data['email'],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 3. SEARCH TAB
class _SearchUsersTab extends StatefulWidget {
  const _SearchUsersTab();

  @override
  State<_SearchUsersTab> createState() => _SearchUsersTabState();
}

class _SearchUsersTabState extends State<_SearchUsersTab> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _doSearch() async {
    if (_searchCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
    });

    // Close keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    final res = await AuthService().searchUsers(_searchCtrl.text.trim());

    if (mounted) {
      setState(() {
        _results = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search username or email...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _doSearch(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loading ? null : _doSearch,
                style: IconButton.styleFrom(
                  backgroundColor: PartyColors.accentPink,
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: PartyColors.accentPink,
                  ),
                )
              : _results.isEmpty
              ? const Center(
                  child: Text(
                    "Enter a name to search",
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, i) {
                    final user = _results[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Text(
                          user['username'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user['username'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        user['email'],
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PartyColors.accentCyan,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          minimumSize: const Size(60, 30),
                        ),
                        onPressed: () async {
                          final msg = await AuthService().sendFriendRequest(
                            user['uid'],
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(msg)));
                          }
                        },
                        child: const Text(
                          "Add",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
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
  final int wins;
  final int streak;

  const _StatsRow({
    required this.games,
    required this.wins,
    required this.streak,
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
          _StatItem(label: "Games Played", value: games.toString()),
          // _StatItem(
          //   label: "Wins",
          //   value: wins.toString(),
          //   color: PartyColors.accentYellow,
          // ),
          _StatItem(label: "Day Streak", value: "$streak 🔥"),
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
  final VoidCallback onManageFriends;

  const _MenuSection({
    required this.isGuest,
    required this.onLogout,
    required this.onManageFriends,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isGuest) ...[
          _ProfileMenuItem(
            icon: Icons.history,
            title: "Game History",
            onTap: () => Navigator.pushNamed(context, "/history"),
          ),
          _ProfileMenuItem(
            icon: Icons.people_outline,
            title: "Manage Friends",
            onTap: onManageFriends,
          ),
        ],
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
