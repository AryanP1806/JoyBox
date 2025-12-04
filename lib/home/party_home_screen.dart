import 'package:flutter/material.dart';
import 'party_theme.dart'; // Ensure this points to your theme file
import '../settings/settings_screen.dart'; // Uncomment if you have this file

class PartyHomeScreen extends StatefulWidget {
  const PartyHomeScreen({super.key});

  @override
  State<PartyHomeScreen> createState() => _PartyHomeScreenState();
}

class _PartyHomeScreenState extends State<PartyHomeScreen> {
  int _currentIndex = 0;

  // The list of "Pages" to switch between without a new screen
  final List<Widget> _pages = [
    const _HomeView(), // Index 0: Home
    const _PlaceholderView(
      title: "Saved",
      icon: Icons.bookmark_border,
    ), // Index 1: Saved
    const SettingsScreen(), // Index 2: Settings (Updated)
    const _ProfileView(), // Index 3: Profile
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartyColors.background,
      // The content switches based on _currentIndex
      body: _pages[_currentIndex],
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ==============================================================================
// 1. HOME VIEW (Extracted from your original build method)
// ==============================================================================

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const _Header(),
          const SizedBox(height: 16),
          const _SearchBar(),
          const SizedBox(height: 24),
          const _SectionHeader(),
          const SizedBox(height: 8),

          // Main scroll
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _GameCard(
                  title: "Most Likely To...",
                  description:
                      "Vote on who in the group is most likely to do something wild.",
                  gradientStart: const Color(0xFFFFA726),
                  gradientEnd: const Color(0xFFFF7043),
                  emoji: "🤔",
                  tag: "Party Fun",
                  onTap: () => Navigator.pushNamed(context, "/mostLikely"),
                ),
                _GameCard(
                  title: "Spy",
                  description:
                      "Everyone knows the location—except one. Can you spot the spy?",
                  gradientStart: const Color(0xFFFF6B3D),
                  gradientEnd: const Color(0xFFED4337),
                  emoji: "🕵️",
                  tag: "Social Deduction",
                  onTap: () => Navigator.pushNamed(context, "/spy"),
                ),
                _GameCard(
                  title: "Never Have I Ever",
                  description:
                      "Secrets, confessions, and drinks. Who has done it?",
                  gradientStart: const Color(0xFF11998e),
                  gradientEnd: const Color(0xFF38ef7d),
                  emoji: "🍺",
                  tag: "Drinking Game",
                  onTap: () => Navigator.pushNamed(context, "/ViralOrFlop"),
                ),
                _GameCard(
                  title: "Mr White",
                  description:
                      "One player got no word. Talk smart and catch the liar.",
                  gradientStart: const Color(0xFF434343),
                  gradientEnd: const Color(0xFF000000),
                  emoji: "🤍",
                  tag: "Word Game",
                  onTap: () => Navigator.pushNamed(context, "/mrWhite"),
                ),
                _GameCard(
                  title: "Mafia Night",
                  description:
                      "Mafia, doctor, detective. Talk, lie and vote to survive.",
                  gradientStart: const Color(0xFF9B51E0),
                  gradientEnd: const Color(0xFF2D9CDB),
                  emoji: "🎭",
                  tag: "Party Classic",
                  onTap: () => Navigator.pushNamed(context, "/mafia"),
                ),
                _GameCard(
                  title: "Truth or Dare",
                  description:
                      "Spicy, funny or brutal. Pick a pack and let chaos begin.",
                  gradientStart: const Color(0xFFFF4ECD),
                  gradientEnd: const Color(0xFF2F80ED),
                  emoji: "🎲",
                  tag: "Icebreaker",
                  onTap: () => Navigator.pushNamed(context, "/truthDare"),
                ),
                _GameCard(
                  title: "Heads Up!",
                  description: "Hold the phone to your head and act it out.",
                  gradientStart: const Color(0xFF56CCF2),
                  gradientEnd: const Color(0xFF00B894),
                  emoji: "🤪",
                  tag: "Act It Out",
                  onTap: () => Navigator.pushNamed(context, "/headsUp"),
                ),
                _GameCard(
                  title: "Wink Assassin",
                  description:
                      "One killer. One detective. Only a single accusation to save everyone.",
                  gradientStart: const Color(0xFF41295A),
                  gradientEnd: const Color(0xFF2F0743),
                  emoji: "🗡️",
                  tag: "Bluff Game",
                  onTap: () => Navigator.pushNamed(context, "/assassin"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 2. PROFILE VIEW (Integrated directly here)
// ==============================================================================

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            // Custom Top Bar for Profile
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    // Edit Profile logic
                  },
                  icon: const Icon(Icons.edit, color: PartyColors.accentCyan),
                ),
              ],
            ),
            const _ProfileHeader(),
            const SizedBox(height: 24),
            const _StatsRow(),
            const SizedBox(height: 24),
            const _ProUpgradeCard(),
            const SizedBox(height: 24),
            const _MenuSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 3. SETTINGS VIEW (Integrated)
// ==============================================================================

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  // Using a local mock since AppSettings isn't in this file context
  final _AppSettings settings = _AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: PartyColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Don't show back button in tabs
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

            _buildToggle(
              title: "Adult Mode (18+)",
              value: settings.adultEnabled,
              onChanged: () {
                setState(() => settings.toggleAdultMode());
              },
            ),

            const SizedBox(height: 24),
            const Divider(color: PartyColors.textSecondary),
            const SizedBox(height: 16),

            const Text(
              "More settings coming soon...",
              style: TextStyle(color: PartyColors.textSecondary),
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
            activeColor: PartyColors.accentPink,
            activeTrackColor: PartyColors.accentPink.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

// Simple Mock for AppSettings to make the code functional without external files
class _AppSettings {
  static final _AppSettings instance = _AppSettings._();
  _AppSettings._();

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool adultEnabled = false;

  void toggleSound() => soundEnabled = !soundEnabled;
  void toggleVibration() => vibrationEnabled = !vibrationEnabled;
  void toggleAdultMode() => adultEnabled = !adultEnabled;
}

// ==============================================================================
// 4. HELPER WIDGETS
// ==============================================================================

/// TOP AREA: Logo + mode toggle
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "JOYBOX",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: PartyColors.accentYellow,
                  shadows: [
                    Shadow(
                      blurRadius: 12,
                      color: PartyColors.accentYellow.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              const Text(
                "Real play. Anytime.",
                style: TextStyle(
                  fontSize: 12,
                  color: PartyColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: PartyColors.card,
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: const Row(
              children: [
                SizedBox(width: 4),
                Text(
                  "Aryan Pore",
                  style: TextStyle(
                    color: PartyColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: PartyColors.card,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: PartyColors.textSecondary),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                style: TextStyle(color: PartyColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Help me find a game",
                  hintStyle: TextStyle(color: PartyColors.textSecondary),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: PartyColors.accentCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.tune,
                size: 18,
                color: PartyColors.accentCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Text(
            "Sort by",
            style: TextStyle(
              color: PartyColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Text(
              "Popular",
              style: TextStyle(
                color: PartyColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            label: const Icon(
              Icons.expand_more,
              size: 20,
              color: PartyColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final String tag;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.emoji,
    required this.tag,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- PROFILE COMPONENTS ---

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: PartyColors.background,
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: PartyColors.card,
              child: Text(
                "AP",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Aryan Pore",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "@aryan_plays",
          style: TextStyle(fontSize: 14, color: PartyColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

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
        children: const [
          _StatItem(label: "Games", value: "142"),
          _StatItem(
            label: "Wins",
            value: "89",
            color: PartyColors.accentYellow,
          ),
          _StatItem(label: "Streak", value: "5 🔥"),
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
    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 24),
          ),
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
                const SizedBox(height: 4),
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
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileMenuItem(
          icon: Icons.history,
          title: "Game History",
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.favorite_border,
          title: "Liked Packs",
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.people_outline,
          title: "Friends",
          badgeCount: 3,
          onTap: () {},
        ),
        const SizedBox(height: 24),
        _ProfileMenuItem(
          icon: Icons.settings_outlined,
          title: "Settings",
          onTap: () {}, // Handled by bottom nav usually, but kept for logic
        ),
        _ProfileMenuItem(
          icon: Icons.logout,
          title: "Log Out",
          isDestructive: true,
          onTap: () {},
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
  final int badgeCount;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.badgeCount = 0,
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
              if (badgeCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PartyColors.accentPink,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    "$badgeCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

// ==============================================================================
// 4. SHARED & NAV COMPONENTS
// ==============================================================================

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: PartyColors.background,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: PartyColors.accentPink,
      unselectedItemColor: PartyColors.textSecondary,
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          label: "Saved",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderView({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: PartyColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            "$title Coming Soon",
            style: const TextStyle(
              color: PartyColors.textSecondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// (Kept for later if you decide to re-enable it, but NOT used in the layout now)
class _StartGameNightCard extends StatelessWidget {
  const _StartGameNightCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start Game Night",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Play a mix of your best games\nback-to-back with one tap.",
                    style: TextStyle(
                      color: PartyColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: const [
                Icon(Icons.groups, color: Colors.white, size: 32),
                SizedBox(height: 6),
                Icon(Icons.celebration, color: Colors.yellowAccent, size: 26),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
