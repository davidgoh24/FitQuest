import 'package:flutter/material.dart';

class AllFriendsTab extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final Function(Map<String, dynamic> friend) onFriendTap;
  const AllFriendsTab({
    Key? key,
    required this.friends,
    required this.onFriendTap,
  }) : super(key: key);

  String safeAvatar(String? path) {
    return (path == null || path.isEmpty) ? 'assets/background/black.jpg' : path;
  }

  String safeBackground(String? path) {
    return (path == null || path.isEmpty) ? 'assets/background/black.jpg' : path;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (friends.isEmpty) {
      return Center(
        child: Text(
          'No friends found.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: friends.length,
      itemBuilder: (context, i) {
        final f = friends[i];
        final unread = f['unread_count'] ?? 0;
        return ListTile(
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  safeBackground(f['background_url']),
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: CircleAvatar(
                backgroundImage: AssetImage(safeAvatar(f['avatar_url'])),
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
          trailing: unread > 0
              ? Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
            child: Text(
              unread.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onError,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : null,
          onTap: () => onFriendTap(f),
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