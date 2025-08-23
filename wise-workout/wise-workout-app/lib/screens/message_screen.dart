import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'add_friend_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/all_friends.dart';
import '../widgets/requests_friends.dart';
import '../widgets/pending_friends.dart';
import '../services/friend_service.dart';
import '../services/message_service.dart';
import 'package:easy_localization/easy_localization.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int selectedTab = 0;
  String search = '';
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> pending = [];
  bool loading = true;
  final FriendService _friendService = FriendService();

  String safeAvatar(String? path) {
    return (path == null || path.isEmpty) ? 'assets/avatars/free/free1.png' : path;
  }

  String safeBackground(String? path) {
    return (path == null || path.isEmpty) ? 'assets/background/black.jpg' : path;
  }

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  Future<void> _loadFriendsData() async {
    if (!mounted) return;
    setState(() { loading = true; });
    try {
      final friendsList = await _friendService.getFriends();
      final pendingList = await _friendService.getPendingRequests();
      final sentList = await _friendService.getSentRequests();
      final unreadCountsList = await MessageService().getUnreadCounts();
      if (!mounted) return;
      final Map<int, int> unreadMap = {
        for (var item in unreadCountsList)
          item['sender_id'] as int: item['unread'] as int
      };
      final mergedFriends = friendsList.map<Map<String, dynamic>>((f) {
        final int friendId = f['id'];
        return {
          ...f,
          'unread_count': unreadMap[friendId] ?? 0,
        };
      }).toList();
      if (!mounted) return;
      setState(() {
        friends = List<Map<String, dynamic>>.from(mergedFriends);
        requests = List<Map<String, dynamic>>.from(pendingList);
        pending = List<Map<String, dynamic>>.from(sentList);
        loading = false;
      });
    } catch (e, stack) {
      if (!mounted) return;
      setState(() {
        friends = [];
        requests = [];
        pending = [];
        loading = false;
      });
    }
  }

  void acceptRequest(int friendId) async {
    try {
      await _friendService.acceptRequest(friendId.toString());
      if (!mounted) return;
      setState(() {
        requests.removeWhere((f) => f['id'] == friendId);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('message_accept_success'.tr() )),
      );
      await _loadFriendsData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('message_accept_fail'.tr() )),
      );
    }
  }

  void ignoreRequest(int friendId) async {
    try {
      await _friendService.rejectRequest(friendId.toString());
      if (!mounted) return;
      setState(() {
        requests.removeWhere((f) => f['id'] == friendId);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('message_ignore_success'.tr() )),
      );
      await _loadFriendsData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('message_ignore_fail'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredFriends = friends
        .where((f) =>
    (f['name'] ?? f['username'] ?? '').toLowerCase().contains(search.toLowerCase()) ||
        (f['handle'] ?? f['email'] ?? '').toLowerCase().contains(search.toLowerCase()))
        .toList()
        .cast<Map<String, dynamic>>();
    final filteredRequests = requests
        .where((f) =>
    (f['name'] ?? f['username'] ?? '').toLowerCase().contains(search.toLowerCase()) ||
        (f['handle'] ?? f['email'] ?? '').toLowerCase().contains(search.toLowerCase()))
        .toList()
        .cast<Map<String, dynamic>>();
    final filteredPending = pending
        .where((f) =>
    (f['name'] ?? f['username'] ?? '').toLowerCase().contains(search.toLowerCase()) ||
        (f['handle'] ?? f['email'] ?? '').toLowerCase().contains(search.toLowerCase()))
        .toList()
        .cast<Map<String, dynamic>>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'message_friends'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => search = v),
                decoration: InputDecoration(
                  hintText: 'message_search_hint'.tr(),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tabButton(context, 'message_tab_all'.tr(), 0, selectedTab == 0, colorScheme),
                    _tabButton(context, 'message_tab_requests'.tr(), 1, selectedTab == 1, colorScheme),
                    _tabButton(context, 'message_tab_pending'.tr(), 2, selectedTab == 2, colorScheme),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 6.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddFriendScreen()),
                          ).then((_) async {
                            if (!mounted) return;
                            await _loadFriendsData();
                          });
                        },
                        icon: Icon(Icons.add, color: colorScheme.onPrimary, size: 18),
                        label: Text('message_add_new'.tr()),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 15),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 0, thickness: 1),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                color: colorScheme.surface,
                child: Builder(builder: (context) {
                  if (selectedTab == 0) {
                    return AllFriendsTab(
                      friends: filteredFriends,
                      onFriendTap: (friend) async {
                        await MessageService().markAsRead(friend['id']);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              friendId: friend['id'],
                              friendName: friend['name'] ?? friend['username'] ?? '',
                              friendHandle: friend['handle'] ?? friend['email'] ?? '',
                              friendAvatar: safeAvatar(friend['avatar_url']),
                              friendBackground: safeBackground(friend['background_url']),
                              isPremium: (friend['role'] ?? '') == 'premium',
                            ),
                          ),
                        );
                        if (!mounted) return;
                        await _loadFriendsData();
                      },
                    );
                  } else if (selectedTab == 1) {
                    return RequestsTab(
                      requests: filteredRequests,
                      acceptRequest: acceptRequest,
                      ignoreRequest: ignoreRequest,
                    );
                  } else {
                    return PendingTab(
                      pending: filteredPending,
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(
        currentIndex: 3,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/leaderboard');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/workout-dashboard');
              break;
            case 3:
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _tabButton(BuildContext context, String label, int idx, bool selected, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: idx == 0 ? 16 : 4),
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
          decoration: BoxDecoration(
            color: selected ? colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondary,
              fontWeight: selected ? FontWeight.bold : FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}