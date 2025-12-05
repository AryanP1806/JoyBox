import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/party_theme.dart';
import 'package:intl/intl.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.card,
        elevation: 0,
        title: const Text(
          "Game History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                "Please login",
                style: TextStyle(color: Colors.white),
              ),
            )
          : _HistoryStream(userId: user.uid),
    );
  }
}

class _HistoryStream extends StatelessWidget {
  final String userId;

  const _HistoryStream({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("history")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firestore Error: ${snapshot.error}");
          return Center(
            child: Text(
              "Something went wrong.\nCheck console for details.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: PartyColors.accentPink),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _emptyView();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            // ✅ CHANGED: Pass the whole data map to the card
            return _HistoryCard(data: data);
          },
        );
      },
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.videogame_asset, size: 60, color: Colors.white30),
          SizedBox(height: 12),
          Text(
            "No games played yet",
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _HistoryCard({required this.data});

  String _formatDate(Timestamp? t) {
    if (t == null) return "Unknown date";
    final dt = t.toDate();
    return DateFormat("d MMM • hh:mm a").format(dt);
  }

  // ✅ NEW: Logic to show full details
  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PartyColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          data['game'] ?? "Game Details",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries
                .where((e) {
                  // Hide keys that are already shown on the main card or technical
                  return !['game', 'won', 'timestamp', 'uid'].contains(e.key);
                })
                .map((e) {
                  // Format key to look nice (e.g. "friends_count" -> "FRIENDS COUNT")
                  final key = e.key.replaceAll('_', ' ').toUpperCase();
                  final value = e.value.toString();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$key: ",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: PartyColors.accentPink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameName = data["game"] ?? "Unknown Game";
    final won = data["won"] ?? false;
    final timestamp = data["timestamp"] as Timestamp?;

    // Fallback: If 'streak' exists, use it, otherwise ignore
    final streak = data["streak"];

    final color = won ? Colors.greenAccent : Colors.redAccent;
    final icon = won ? Icons.check_circle : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PartyColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Only show streak here if it exists, otherwise show date
                if (streak != null)
                  Text(
                    "Streak: $streak",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                if (streak != null) const SizedBox(height: 4),
                Text(
                  _formatDate(timestamp),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          // ✅ NEW: The Details Icon
          IconButton(
            onPressed: () => _showDetails(context),
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            tooltip: "See Details",
          ),
        ],
      ),
    );
  }
}
