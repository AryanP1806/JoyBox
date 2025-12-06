import 'package:flutter/material.dart';

class QuickDrawResultsScreen extends StatelessWidget {
  final int avgTime;
  final int bestTime;
  final int earlyTaps;

  const QuickDrawResultsScreen({
    super.key,
    required this.avgTime,
    required this.bestTime,
    required this.earlyTaps,
  });

  String get _rating {
    if (avgTime < 200) return "GODLIKE ⚡";
    if (avgTime < 250) return "PRO GAMER 🎮";
    if (avgTime < 300) return "AVERAGE HUMAN 👤";
    if (avgTime < 400) return "SLEEPY? 😴";
    return "TURTLE 🐢";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SESSION REPORT",
              style: TextStyle(
                color: Colors.white54,
                letterSpacing: 4,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            _statDisplay("AVERAGE", "$avgTime ms", Colors.cyanAccent),
            const SizedBox(height: 20),
            _statDisplay("BEST", "$bestTime ms", Colors.greenAccent),
            const SizedBox(height: 20),
            _statDisplay("FAILS", "$earlyTaps", Colors.redAccent),

            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _rating,
                style: const TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context); // Back to Setup
              },
              child: const Text("DONE"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            fontFamily: 'Courier',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
