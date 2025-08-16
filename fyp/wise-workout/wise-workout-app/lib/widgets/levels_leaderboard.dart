import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';

class LevelsLeaderboardWidget extends StatefulWidget {
  const LevelsLeaderboardWidget({super.key});

  @override
  State<LevelsLeaderboardWidget> createState() => _LevelsLeaderboardWidgetState();
}

class _LevelsLeaderboardWidgetState extends State<LevelsLeaderboardWidget> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final data = await LeaderboardService().fetchLeaderboard(type: 'levels', limit: 20);
      setState(() {
        users = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) return Center(child: Text(error));
    if (users.isEmpty) return const Center(child: Text('No leaderboard data'));

    final top3 = users.take(3).toList();
    final others = users.skip(3).toList();

    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Top Levels',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (top3.length > 1) _buildTopUser(user: top3[1], size: 60),
            if (top3.isNotEmpty) _buildTopUser(user: top3[0], size: 72),
            if (top3.length > 2) _buildTopUser(user: top3[2], size: 60),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              itemCount: others.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = others[index];
                return ListTile(
                  leading: _buildAvatarWithBackground(user, 32),
                  title: Text(
                    user['username'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lv. ${user['level'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopUser({required Map<String, dynamic> user, required double size}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildAvatarWithBackground(user, size),
        const SizedBox(height: 6),
        Text(
          user['username'] ?? '',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Lv. ${user['level'] ?? ''}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWithBackground(Map<String, dynamic> user, double size) {
    final avatarUrl = (user['avatar_url'] == null || user['avatar_url'].toString().isEmpty)
        ? 'assets/background/black.jpg'
        : user['avatar_url'];
    final backgroundUrl = (user['background_url'] == null || user['background_url'].toString().isEmpty)
        ? 'assets/background/black.jpg'
        : user['background_url'];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image(
              image: _getImageProvider(backgroundUrl),
              fit: BoxFit.cover,
              width: size,
              height: size,
            ),
          ),
          CircleAvatar(
            radius: size * 0.5,
            backgroundImage: _getImageProvider(avatarUrl),
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(dynamic url) {
    if (url == null || url.toString().isEmpty) {
      return const AssetImage('assets/background/black.jpg');
    }
    if (url.toString().startsWith('http')) {
      return NetworkImage(url.toString());
    }
    return AssetImage(url.toString());
  }
}