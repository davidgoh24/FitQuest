import 'package:flutter/material.dart';

class TournamentCard extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final VoidCallback? onJoin;

  const TournamentCard({
    super.key,
    required this.tournament,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tournament['title'] ?? '',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            tournament['description'] ?? '',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            tournament['endDate'] ?? '',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          ...(tournament['features'] as List<dynamic>? ?? []).map((feature) {
            return Row(
              children: [
                Icon(Icons.check, size: 16, color: colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  feature.toString(),
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                ),
              ],
            );
          }).toList(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                'Join',
                style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showTournamentJoinPopup(BuildContext context, Map<String, dynamic> tournament, {VoidCallback? onJoin}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(ctx).pop(),
        child: GestureDetector(
          onTap: () {}, // Prevent tap-through
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                padding: const EdgeInsets.all(24),
                child: ListView(
                  controller: controller,
                  children: [
                    Text(
                      tournament['title'] ?? '',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tournament['description'] ?? '',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "What's Included:",
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...((tournament['features'] as List<dynamic>? ?? []).map((feature) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("• ",
                                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.secondary)),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                    )),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: ctx,
                          builder: (ctx2) => AlertDialog(
                            title: const Text('Join Tournament'),
                            content: const Text('Are you sure you want to join this tournament?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(ctx2).pop(false),
                              ),
                              TextButton(
                                child: const Text('Join'),
                                onPressed: () => Navigator.of(ctx2).pop(true),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        if (onJoin != null) onJoin!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Join',
                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}