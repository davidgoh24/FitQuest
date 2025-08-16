import 'package:flutter/material.dart';
import '../services/daily_quest_service.dart';
import '../widgets/bottom_navigation.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({Key? key}) : super(key: key);

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  List<Map<String, dynamic>> _quests = [];
  bool _loading = true;
  bool _claiming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQuests();
  }

  Future<void> _fetchQuests() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final quests = await DailyQuestService().fetchDailyQuests();
      setState(() {
        _quests = quests;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _claimXP(int i) async {
    if (_claiming) return;
    setState(() => _claiming = true);
    try {
      final questCode = _quests[i]['quest_code'] as String;
      await DailyQuestService().claimQuest(questCode);
      await _fetchQuests();
    } catch (e) {
      // Optionally show a snackbar with error
    } finally {
      setState(() => _claiming = false);
    }
  }

  Future<void> _claimAllXP() async {
    if (_claiming) return;
    setState(() => _claiming = true);
    try {
      await DailyQuestService().claimAllQuests();
      await _fetchQuests();
    } catch (e) {
      // Optionally show a snackbar with error
    } finally {
      setState(() => _claiming = false);
    }
  }

  Widget questCard(int i) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quest = _quests[i];
    final String text = quest['text'] ?? '';
    final bool done = quest['done'] == 1 || quest['done'] == true;
    final bool claimed = quest['claimed'] == 1 || quest['claimed'] == true;

    final cardColor = done ? colorScheme.primaryContainer : colorScheme.surface;
    final textColor = done ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final buttonBg = colorScheme.secondary;
    final buttonFg = colorScheme.onSecondary;
    final checkIconColor = colorScheme.secondary;
    final claimIconColor = colorScheme.secondary;
    final claimAllIconColor = colorScheme.secondary;
    final finishedBorder = colorScheme.outline;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (done && !claimed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBg,
                foregroundColor: buttonFg,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _claiming ? null : () => _claimXP(i),
              child: Text('quest_button_claim'.tr()),
            )
          else if (done && claimed)
            Icon(Icons.check_circle, color: checkIconColor, size: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final int unclaimedCount = _quests
        .where((q) =>
    (q['done'] == 1 || q['done'] == true) &&
        (q['claimed'] == 0 || q['claimed'] == false))
        .length;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          if (_loading)
            Center(child: CircularProgressIndicator(color: colorScheme.primary))
          else if (_error != null)
            Center(child: Text(_error!, style: TextStyle(color: colorScheme.error)))
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _quests.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      padding: const EdgeInsets.only(top: 40, bottom: 30, left: 18, right: 18),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(34),
                          bottomRight: Radius.circular(34),
                        ),
                      ),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(30),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.arrow_back, color: colorScheme.onPrimary, size: 26),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              'quest_title'.tr(),
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              'quest_subtitle'.tr(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.7),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (index == 1) {
                    return const SizedBox(height: 32);
                  } else {
                    return questCard(index - 2);
                  }
                },
              ),
            ),
          if (!_loading && unclaimedCount > 1)
            Positioned(
              left: 16,
              right: 16,
              bottom: 66,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _claiming ? null : _claimAllXP,
                  icon: Icon(Icons.star, color: colorScheme.secondary),
                  label: Text(
                    'quest_button_claim_all'.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/leaderboard');
              break;
            case 2:
              Navigator.pushNamed(context, '/workout-category-dashboard');
              break;
            case 3:
              Navigator.pushNamed(context, '/messages');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}