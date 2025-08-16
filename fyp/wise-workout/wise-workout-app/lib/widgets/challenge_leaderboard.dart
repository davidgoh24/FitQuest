import 'package:flutter/material.dart';
import '../services/challenge_service.dart';

class ChallengeLeaderboardWidget extends StatefulWidget {
  const ChallengeLeaderboardWidget({super.key});

  @override
  State<ChallengeLeaderboardWidget> createState() => _ChallengeLeaderboardWidgetState();
}

class _ChallengeLeaderboardWidgetState extends State<ChallengeLeaderboardWidget> {
  final ChallengeService _service = ChallengeService();
  late Future<List<_ChallengeGroup>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_ChallengeGroup>> _load() async {
    final rows = await _service.getLeaderboard();
    final byInvite = <int, List<_LeaderRow>>{};
    for (final m in rows) {
      final r = _LeaderRow.fromMap(m);
      byInvite.putIfAbsent(r.inviteId, () => []).add(r);
    }

    final groups = <_ChallengeGroup>[];
    byInvite.forEach((inviteId, list) {
      if (list.isEmpty) return;
      final first = list.first;
      groups.add(_ChallengeGroup(
        inviteId: inviteId,
        title: first.type,
        target: '${first.value} ${first.unit}',
        daysLeft: first.daysLeft,
        totalDays: first.totalDays,
        participants: list.map((e) => e.username).toList(),
        values: list.map((e) => e.progress).toList(),
        isCompleted: first.isCompleted,
      ));
    });

    groups.sort((a, b) {
      int rankA = a.daysLeft > 0 && !a.isCompleted ? 0 : (a.isCompleted ? 1 : 2);
      int rankB = b.daysLeft > 0 && !b.isCompleted ? 0 : (b.isCompleted ? 1 : 2);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return a.daysLeft.compareTo(b.daysLeft);
    });

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ChallengeGroup>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: Text(
              'Failed to load leaderboard',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          );
        }

        final groups = snap.data!;
        if (groups.isEmpty) {
          return Center(
            child: Text('No active challenges', style: Theme.of(context).textTheme.bodyMedium),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final g = groups[i];
            final isActive = g.daysLeft > 0 && !g.isCompleted;
            final durationText = isActive
                ? '${g.daysLeft} day${g.daysLeft == 1 ? '' : 's'} left'
                : (g.isCompleted ? 'Completed' : 'Expired');

            return _buildChallengeCard(
              context: context,
              title: g.title,
              target: g.target,
              duration: durationText,
              participants: g.participants,
              values: g.values,
              isActive: isActive,
              isCompleted: g.isCompleted,
            );
          },
        );
      },
    );
  }

  Widget _buildChallengeCard({
    required BuildContext context,
    required String title,
    required String target,
    required String duration,
    required List<String> participants,
    required List<int> values,
    required bool isActive,
    required bool isCompleted,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barMaxHeight = 120.0;
    final maxVal = values.isEmpty ? 0.0 : values.fold<double>(0, (p, n) => n > p ? n.toDouble() : p);
    final safeMax = maxVal.isFinite && maxVal > 0 ? maxVal : 1.0;

    String statusText;
    Color statusColor;
    if (isActive) {
      statusText = '• In Progress';
      statusColor = Colors.green;
    } else if (isCompleted) {
      statusText = '• Completed';
      statusColor = Colors.blue;
    } else {
      statusText = '• Expired';
      statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              statusText,
              style: theme.textTheme.bodyMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w500),
            ),
          ]),
          const SizedBox(height: 6),
          Text('Target: $target', style: theme.textTheme.bodySmall),
          Text('Duration: $duration', style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(participants.length, (index) {
                final name = participants[index];
                final raw = index < values.length ? values[index] : 0;
                final v = raw.toDouble();
                final ratio = (v / safeMax);
                final safeRatio = ratio.isFinite && !ratio.isNaN ? ratio.clamp(0.0, 1.0) : 0.0;
                final fillHeight = barMaxHeight * safeRatio;

                const minLabelHeight = 28.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: barMaxHeight + 24,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: 36,
                            height: barMaxHeight,
                            decoration: BoxDecoration(
                              color: _getColor(index).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: fillHeight,
                            decoration: BoxDecoration(
                              color: _getColor(index),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: fillHeight >= minLabelHeight
                                ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$raw',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '/${maxVal.isFinite ? maxVal.toInt() : 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        name,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(int index) {
    const colors = [
      Color(0xFFD32F2F),
      Color(0xFFFFC107),
      Color(0xFFEC407A),
      Color(0xFF7E57C2),
      Color(0xFF26C6DA),
    ];
    return colors[index % colors.length];
  }
}

class _LeaderRow {
  final int inviteId;
  final String type;
  final int value;
  final String unit;
  final int totalDays;
  final int daysLeft;
  final String username;
  final int progress;
  final bool isCompleted;

  _LeaderRow({
    required this.inviteId,
    required this.type,
    required this.value,
    required this.unit,
    required this.totalDays,
    required this.daysLeft,
    required this.username,
    required this.progress,
    required this.isCompleted,
  });

  factory _LeaderRow.fromMap(Map<String, dynamic> m) {
    return _LeaderRow(
      inviteId: (m['invite_id'] as num?)?.toInt() ?? 0,
      type: (m['type'] ?? '').toString(),
      value: (m['value'] as num?)?.toInt() ?? 0,
      unit: (m['unit'] ?? '').toString(),
      totalDays: (m['total_days'] as num?)?.toInt() ?? 0,
      daysLeft: (m['days_left'] as num?)?.toInt() ?? 0,
      username: (m['username'] ?? '').toString(),
      progress: (m['progress'] as num?)?.toInt() ?? 0,
      isCompleted: (m['is_completed'] == 1),
    );
  }
}

class _ChallengeGroup {
  final int inviteId;
  final String title;
  final String target;
  final int daysLeft;
  final int totalDays;
  final List<String> participants;
  final List<int> values;
  final bool isCompleted;

  _ChallengeGroup({
    required this.inviteId,
    required this.title,
    required this.target,
    required this.daysLeft,
    required this.totalDays,
    required this.participants,
    required this.values,
    required this.isCompleted,
  });
}