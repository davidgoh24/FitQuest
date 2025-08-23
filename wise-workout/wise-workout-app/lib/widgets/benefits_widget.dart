import 'package:flutter/material.dart';

class BenefitsWidget extends StatelessWidget {
  const BenefitsWidget({Key? key}) : super(key: key);

  Widget _benefitTile(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = colorScheme.primaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Column(
          children: [
            _benefitTile(context, Icons.block, "100% Ad-free experience"),
            _benefitTile(context, Icons.emoji_emotions, "Exclusive avatar selections"),
            _benefitTile(context, Icons.smart_toy, "Auto-suggested plan with AI"),
            _benefitTile(context, Icons.play_circle_filled, "Step-by-step HD video tutorials"),
            _benefitTile(context, Icons.flash_on, "Priority support and faster updates"),
          ],
        ),
      ),
    );
  }
}