import 'package:flutter/material.dart';

class IncludedWidget extends StatelessWidget {
  const IncludedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Fitness plans for all levels", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text("• Advanced progress tracking", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text("• Access to new AI-powered features", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text("• Access future new content immediately", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text("• Support the app’s ongoing development ❤️", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}