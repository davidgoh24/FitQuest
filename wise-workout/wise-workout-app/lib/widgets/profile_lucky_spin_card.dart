import 'package:flutter/material.dart';
import '../screens/lucky_spin_screen.dart';


class ProfileLuckySpinCard extends StatelessWidget {
  final int tokens;
  final Function(int) onSpinComplete;

  const ProfileLuckySpinCard({
    Key? key,
    required this.tokens,
    required this.onSpinComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final updatedTokens = await Navigator.push<int>(
          context,
          MaterialPageRoute(builder: (_) => LuckySpinScreen(tokens: tokens)),
        );
        if (updatedTokens != null) {
          onSpinComplete(updatedTokens);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF071655),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Lucky Spin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text("$tokens Tokens", style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const Icon(Icons.stars, color: Colors.amber, size: 32),
          ],
        ),
      ),
    );
  }
}