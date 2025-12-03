import 'package:flutter/material.dart';
import 'party_theme.dart';
import '../settings/settings_screen.dart';

class PartyHomeScreen extends StatelessWidget {
  const PartyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartyColors.background,
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
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
                    title: "Mr White",
                    description:
                        "One player got no word. Talk smart and catch the liar.",
                    gradientStart: const Color(0xFFF2C94C),
                    gradientEnd: const Color(0xFFE67E22),
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
                    gradientStart: const Color(0xFF41295A), // dark purple
                    gradientEnd: const Color(0xFF2F0743), // assassin vibe
                    emoji: "🗡️",
                    tag: "Bluff Game",
                    onTap: () => Navigator.pushNamed(context, "/assassin"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          // App "logo"
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
          // Night-mode pill (visual only for now)
          Container(
            decoration: BoxDecoration(
              color: PartyColors.card,
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: const Row(
              children: [
                // Icon(Icons.dark_mode, size: 18, color: Colors.white),
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

/// SEARCH BAR
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

/// "Sort by" / section label
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
            onPressed: () {
              // hook up sort options later if you want
            },
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

/// INDIVIDUAL GAME CARD
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
                // Left: emoji icon in a circle
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
                // Center: text
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: PartyColors.background,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: PartyColors.accentPink,
      unselectedItemColor: PartyColors.textSecondary,
      showUnselectedLabels: true,

      onTap: (index) {
        if (index == 2) {
          // ✅ SETTINGS TAB
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tab $index not wired yet.--Desined by Aryan Pore"),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },

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
