import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import '../services/challenge_service.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String target;
  final String duration;
  final VoidCallback onInvite;
  final VoidCallback onEdit;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.target,
    required this.duration,
    required this.onInvite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shadowColor = Theme.of(context).shadowColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(60, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Edit",
                  style: textTheme.labelLarge?.copyWith(fontSize: 13, color: colorScheme.onPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Target: $target",
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontSize: 14),
          ),
          Text(
            "Duration: $duration",
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "+ Challenge Friend",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showInviteFriendPopup(
    BuildContext context,
    String title,
    String target,
    String duration,
    ) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  final challengeService = ChallengeService();
  final Set<int> selectedIndices = {};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: challengeService.getFriendsToChallenge(title),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load friends'));
          }

          final friends = snapshot.data ?? [];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(ctx).pop(),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.7,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Target: $target",
                                    style:
                                    textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                  ),
                                  Text(
                                    "Duration: $duration",
                                    style:
                                    textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                controller: controller,
                                itemCount: friends.length,
                                itemBuilder: (context, index) {
                                  final friend = friends[index];
                                  final isSelected = selectedIndices.contains(index);

                                  final backgroundUrl = friend['background_url'] ?? '';
                                  final avatarUrl = friend['avatar_url'] ?? '';

                                  ImageProvider backgroundImageProvider() {
                                    if (backgroundUrl.isEmpty) return const AssetImage('assets/background/black.jpg');
                                    if (backgroundUrl.startsWith('http')) {
                                      return NetworkImage(backgroundUrl);
                                    }
                                    return AssetImage(backgroundUrl);
                                  }

                                  ImageProvider? avatarImageProvider() {
                                    if (avatarUrl.isEmpty) return null;
                                    if (avatarUrl.startsWith('http')) {
                                      return NetworkImage(avatarUrl);
                                    }
                                    return AssetImage(avatarUrl);
                                  }

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: backgroundImageProvider(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Center(
                                        child: CircleAvatar(
                                          backgroundImage: avatarImageProvider(),
                                          radius: 18,
                                          backgroundColor: Colors.transparent,
                                          child: avatarUrl.isEmpty
                                              ? Icon(Icons.person,
                                              color: colorScheme.onSecondary, size: 20)
                                              : null,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      friend['name'] ?? '',
                                      style: textTheme.bodyLarge
                                          ?.copyWith(color: colorScheme.onSurface),
                                    ),
                                    subtitle: Text(
                                      friend['username'] ?? '',
                                      style: textTheme.bodySmall
                                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                        color: isSelected ? colorScheme.primary : colorScheme.secondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedIndices.remove(index);
                                          } else {
                                            selectedIndices.add(index);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final challengeService = ChallengeService();
                                for (int index in selectedIndices) {
                                  final friend = friends[index];
                                  final durationParts = duration.split(' ');
                                  final customDurationValue = int.tryParse(durationParts[0]) ?? 0;
                                  final customDurationUnit = durationParts.length > 1 ? durationParts[1].toLowerCase() : 'days';

                                  final targetParts = target.split(' ');
                                  final customValue = int.tryParse(targetParts[0]) ?? 0;

                                  await challengeService.sendChallenge(
                                    receiverId: friend['id'],
                                    title: title,
                                    customValue: customValue,
                                    customDurationValue: customDurationValue,
                                    customDurationUnit: customDurationUnit,
                                  );
                                }

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Challenge sent!")),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: Text(
                                "Done",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}
Future<Map<String, String>?> showEditChallengePopup(
  BuildContext context,
  String currentTarget,
  String currentDuration,
) async {
  final targetParts = currentTarget.split(' ');
  String targetAmount = targetParts.isNotEmpty ? targetParts[0] : '';
  String targetUnit = targetParts.length > 1 ? targetParts.sublist(1).join(' ') : '';

  final durationParts = currentDuration.split(' ');
  String durationAmount = durationParts.isNotEmpty ? durationParts[0] : '';
  String durationUnit = durationParts.length > 1 ? durationParts[1].toLowerCase() : 'days';

  final targetAmountController = TextEditingController(text: targetAmount);
  final durationAmountController = TextEditingController(text: durationAmount);

  final durationUnits = ['days', 'weeks', 'months'];
  String selectedDurationUnit = durationUnits.contains(durationUnit) ? durationUnit : durationUnits[0];

  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Challenge'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Target amount input with fixed unit label
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: 100,
                          child: TextField(
                            controller: targetAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Target Amount',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            maxLength: 5,
                            buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            targetUnit,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Duration amount input + duration unit dropdown
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: 100,
                          child: TextField(
                            controller: durationAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Duration',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            maxLength: 3,
                            buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: selectedDurationUnit,
                          decoration: const InputDecoration(labelText: 'Duration Unit'),
                          items: durationUnits
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit.capitalize())))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedDurationUnit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newTarget = '${targetAmountController.text.trim()} $targetUnit';
                  final newDuration = '${durationAmountController.text.trim()} $selectedDurationUnit';
                  Navigator.pop(context, {'target': newTarget, 'duration': newDuration});
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      );
    },
  );
}

extension StringCasingExtension on String {
  String capitalize() => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}