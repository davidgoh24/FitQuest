import 'package:flutter/material.dart';

class MoneyBackWidget extends StatelessWidget {
  const MoneyBackWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final guaranteeColor = Colors.green;
    final guaranteeColorDark = Colors.green[700] ?? guaranteeColor;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.verified, color: guaranteeColorDark, size: 33),
            const SizedBox(width: 14),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "7-Day Money Back Guarantee\n",
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: guaranteeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text:
                      "Try any premium plan risk-free. Cancel anytime in the first 7 days for a full refund.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.83),
                        fontSize: 13.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}