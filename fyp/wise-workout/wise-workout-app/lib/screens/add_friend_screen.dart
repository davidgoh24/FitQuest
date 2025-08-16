import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/friend_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);
  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  String search = '';
  List<dynamic> searchResults = [];
  bool loading = false;
  final FriendService _friendService = FriendService();

  Future<void> _searchUsers(String query) async {
    setState(() { loading = true; });
    try {
      final results = await _friendService.searchUsers(query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
      });
    }
    setState(() { loading = false; });
  }

  Future<void> _sendFriendRequest(String friendId, String name) async {
    try {
      await _friendService.sendRequest(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("friend_request_sent_to".tr(args: [name]))),
      );
      if (search.trim().isNotEmpty) {
        _searchUsers(search.trim());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("friend_request_failed".tr())),
      );
    }
  }

  Widget _buildTrailing(BuildContext context, dynamic u, ColorScheme colorScheme, ThemeData theme) {
    final status = u['relationship_status'];
    final labelStyle = theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold);
    if (status == 'friends') {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(60, 36),
        ),
        child: Text('friend_status_friend'.tr(), style: labelStyle),
      );
    } else if (status == 'sent' || status == 'pending') {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceVariant,
          foregroundColor: colorScheme.onSurfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(60, 36),
        ),
        child: Text(status == 'sent' ? 'friend_status_sent'.tr() : 'friend_status_pending'.tr(), style: labelStyle),
      );
    }
    return ElevatedButton(
      onPressed: () => _sendFriendRequest(
          u['id'].toString(), u['name'] ?? u['username'] ?? ''),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(60, 36),
      ),
      child: Text('friend_status_add'.tr(), style: labelStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'friend_add_title'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color,
            fontSize: 25
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              autofocus: true,
              onChanged: (v) {
                setState(() => search = v);
                if (v.trim().isNotEmpty) {
                  _searchUsers(v.trim());
                } else {
                  setState(() => searchResults = []);
                }
              },
              decoration: InputDecoration(
                hintText: 'friend_search_hint'.tr(),
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 0, thickness: 1),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : (searchResults.isEmpty || search.isEmpty)
                ? Center(
              child: Text(
                "friend_no_users".tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.separated(
              itemCount: searchResults.length,
              separatorBuilder: (_, __) => Divider(
                thickness: 1,
                indent: 24,
                endIndent: 24,
                color: colorScheme.outline,
              ),
              itemBuilder: (context, i) {
                final u = searchResults[i];
                return ListTile(
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(u['background_url'] ?? 'assets/background/black.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        backgroundImage: AssetImage(u['avatar_url'] ?? ''),
                        radius: 22,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  title: Text(
                    u['name'] ?? u['username'] ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: theme.textTheme.titleSmall?.color,
                    ),
                  ),
                  subtitle: Text(
                    u['handle'] ?? u['email'] ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: theme.hintColor,
                    ),
                  ),
                  trailing: _buildTrailing(context, u, colorScheme, theme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
