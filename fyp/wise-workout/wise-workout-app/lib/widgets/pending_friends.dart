import 'package:flutter/material.dart';

class PendingTab extends StatelessWidget {
  final List<Map<String, dynamic>> pending;
  const PendingTab({
    Key? key,
    required this.pending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (pending.isEmpty) {
      return Center(
        child: Text(
          'No pending requests.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: pending.length,
      itemBuilder: (context, i) {
        final f = pending[i];
        return ListTile(
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(f['background_url'] ?? 'assets/background/black.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: CircleAvatar(
                backgroundImage: AssetImage(f['avatar_url'] ?? ''),
                radius: 22,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          title: Text(
            f['name'] ?? f['username'] ?? '',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 17,
              color: theme.textTheme.titleSmall?.color,
            ),
          ),
          subtitle: Text(
            f['handle'] ?? f['email'] ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: theme.hintColor,
            ),
          ),
          trailing: Text(
            "Requested",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => Divider(
        thickness: 1,
        indent: 24,
        endIndent: 24,
        color: colorScheme.outline,
      ),
    );
  }
}