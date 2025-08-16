import 'package:flutter/material.dart';

class RequestsTab extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Function(int) acceptRequest;
  final Function(int) ignoreRequest;
  const RequestsTab({
    Key? key,
    required this.requests,
    required this.acceptRequest,
    required this.ignoreRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No requests.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: requests.length,
      itemBuilder: (context, i) {
        final f = requests[i];
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => acceptRequest(f['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  textStyle: theme.textTheme.labelLarge,
                ),
                child: const Text('Accept'),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () => ignoreRequest(f['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  textStyle: theme.textTheme.labelLarge,
                ),
                child: const Text('Ignore'),
              ),
            ],
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