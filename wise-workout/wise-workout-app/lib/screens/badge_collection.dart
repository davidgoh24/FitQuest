import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/badge_service.dart';

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({Key? key}) : super(key: key);

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen> {
  final BadgeService _badgeService = BadgeService();
  List<Map<String, dynamic>> _badges = [];
  Set<int> _unlockedBadgeIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  Future<void> _fetchBadges() async {
    try {
      final allBadges = await _badgeService.getAllBadges();
      final userBadges = await _badgeService.getUserBadges();
      final userBadgeIds = Set<int>.from(userBadges.map((b) => b['id'] as int));
      setState(() {
        _badges = List<Map<String, dynamic>>.from(allBadges.map((b) => {
          'id': b['id'],
          'image': b['icon_url'],
          'color': [
            '#DCF0F7', '#F0FDD7', '#FFF3AD', '#EAD8FF', '#FFDEDE',
            '#D6EDFF', '#D0F0FF', '#FFD6BD', '#C5F9D7', '#E5E5E5',
            '#FFE6E6', '#D9F0F4',
          ][((b['id'] as int) - 1) % 12],
          'locked': !userBadgeIds.contains(b['id']),
          'name': b['name'],
          'description': b['description'],
        }));
        _unlockedBadgeIds = userBadgeIds;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        title: Text(
          'badge_collections_title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withOpacity(0.19),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'badge_section_label'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: GridView.builder(
                  itemCount: _badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final badge = _badges[index];
                    final isLocked = badge['locked'] as bool;
                    return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => _BadgeDetailDialog(badge: badge),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: HexColor.fromHex(badge['color']),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: ColorFiltered(
                              colorFilter: isLocked
                                  ? ColorFilter.mode(
                                Colors.grey.withOpacity(0.6),
                                BlendMode.saturation,
                              )
                                  : const ColorFilter.mode(
                                  Colors.transparent, BlendMode.multiply),
                              child: Image.asset(
                                badge['image'],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.error_outline, size: 32, color: colorScheme.error),
                              ),
                            ),
                          ),
                          if (isLocked)
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.background.withOpacity(0.44),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock,
                                  color: colorScheme.onBackground.withOpacity(0.82),
                                  size: 40,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeDetailDialog extends StatelessWidget {
  final Map<String, dynamic> badge;
  const _BadgeDetailDialog({required this.badge});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLocked = badge['locked'] as bool;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: HexColor.fromHex(badge['color']),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ColorFiltered(
                    colorFilter: isLocked
                        ? ColorFilter.mode(
                      Colors.grey.withOpacity(0.7),
                      BlendMode.saturation,
                    )
                        : const ColorFilter.mode(
                        Colors.transparent, BlendMode.multiply),
                    child: Image.asset(
                      badge['image'],
                      height: 220,
                      width: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.error_outline,
                          size: 100,
                          color: colorScheme.error),
                    ),
                  ),
                ),
                if (isLocked)
                  Positioned(
                    child: Icon(Icons.lock,
                        color: colorScheme.onSurface.withOpacity(0.88),
                        size: 64),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              isLocked
                  ? "badge_locked_title".tr()
                  : "badge_unlocked_title".tr(),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isLocked) ...[
              Text(
                "badge_how_to_unlock".tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                badge['description'] ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: colorScheme.onSurface),
              ),
            ] else ...[
              Text(
                "badge_unlocked_message".tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: colorScheme.onSurface),
              ),
            ],
            const SizedBox(height: 22),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                textStyle: Theme.of(context).textTheme.titleMedium,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              ),
              child: Text("badge_close_button".tr()),
            )
          ],
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    final colorStr = hexColor.toUpperCase().replaceAll("#", "");
    if (colorStr.length == 6) {
      return int.parse("FF$colorStr", radix: 16);
    } else {
      return int.parse(colorStr, radix: 16);
    }
  }

  HexColor.fromHex(String hexColor) : super(_getColorFromHex(hexColor));
}