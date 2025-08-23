import 'package:flutter/material.dart';

class ProfileInfoRow extends StatelessWidget {
  final String xp;
  final String level;
  final int progressInLevel;
  final int xpForThisLevel;

  const ProfileInfoRow({
    Key? key,
    required this.xp,
    required this.level,
    required this.progressInLevel,
    required this.xpForThisLevel,
  }) : super(key: key);

  Widget _infoCard(BuildContext context, String label, String value, {String? subLabel}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                subLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String progressText = "$progressInLevel / $xpForThisLevel XP";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _infoCard(context, "XP", progressText),
          const SizedBox(width: 15),
          _infoCard(context, "Level", level),
        ],
      ),
    );
  }
}