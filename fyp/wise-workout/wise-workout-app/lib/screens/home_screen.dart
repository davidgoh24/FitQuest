import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/tournament_service.dart';
import '../widgets/tournament_widget.dart';
import '../widgets/app_drawer.dart';
import '../services/health_service.dart';
import '../services/api_service.dart';
import '../services/badge_service.dart';
import '../services/workout_category_service.dart';
import '../services/notification_service.dart';
import '../widgets/exercise_stats_card.dart';
import '../widgets/workout_card_home_screen.dart';
import '../widgets/reminder_widget.dart';
import '../widgets/bottom_navigation.dart';
import '../screens/camera/SquatPoseScreen.dart';
import '../screens/buypremium_screen.dart';
import '../screens/quest_screen.dart';
import '../screens/workout/workout_list_page.dart';
import '../screens/challengeInvitation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/workout_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final Widget? homeIcon;
  final Widget? leaderboardIcon;
  final Widget? messagesIcon;
  final Widget? profileIcon;
  final Widget? workoutIcon;

  const HomeScreen({
    super.key,
    required this.userName,
    this.homeIcon,
    this.leaderboardIcon,
    this.messagesIcon,
    this.profileIcon,
    this.workoutIcon,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HealthService _healthService = HealthService();
  int _currentSteps = 0;
  final int maxSteps = 10000;
  double caloriesBurned = 0.0;
  int xpEarned = 0;
  String? _displayName;
  bool _isPremiumUser = false;
  final BadgeService _badgeService = BadgeService();
  List<String> _unlockedBadges = [];
  late Future<List<dynamic>> tournamentsFuture;

  late Future<List<WorkoutCategory>> _categoryFuture;

  @override
  void initState() {
    super.initState();
    fetchTodaySteps();
    _fetchProfile();
    _fetchUnlockedBadges();
    _requestNotificationPermission();
    _fetchTodayCalories();
    _fetchTodayXP();
    tournamentsFuture = TournamentService().getTournamentsWithParticipants();
    _categoryFuture = WorkoutCategoryService().fetchCategories();
  }

  Future<void> reloadTournaments() async {
    setState(() {
      tournamentsFuture = TournamentService().getTournamentsWithParticipants();
    });
  }

  double _toOneDecimal(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is int) return v.toDouble();
    if (v is double) return double.parse(v.toStringAsFixed(1));
    if (v is num) return double.parse(v.toDouble().toStringAsFixed(1));
    if (v is String) {
      final parsed = num.tryParse(v);
      if (parsed != null) {
        return double.parse(parsed.toDouble().toStringAsFixed(1));
      }
    }
    return fallback;
  }

  Future<void> _fetchTodayCalories() async {
    try {
      final summary = await WorkoutService().fetchTodayCaloriesSummary();
      final total = _toOneDecimal(summary['totalCalories']);
      setState(() => caloriesBurned = total);
      debugPrint('DEBUG: Calories fetched (1 decimal): $total');
    } catch (e, st) {
      debugPrint('Error fetching today calories: $e\n$st');
    }
  }

  Future<void> _fetchTodayXP() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final xp = await ApiService().getDailyXP(today);
      setState(() {
        xpEarned = xp;
      });
    } catch (e) {
      print('Error fetching today XP: $e');
    }
  }



  Future<void> _requestNotificationPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
  Future<void> fetchTodaySteps() async {
    final connected = await _healthService.connect();
    if (connected) {
      final steps = await _healthService.getTodaySteps();
      setState(() => _currentSteps = steps);
    }
  }

  Future<void> _fetchProfile() async {
    final profile = await ApiService().getCurrentProfile();
    if (profile != null) {
      setState(() {
        _displayName = profile['username'];
        _isPremiumUser = profile['role'] == 'premium';
      });
    }
  }

  Future<void> _fetchUnlockedBadges() async {
    try {
      final badges = await _badgeService.getUserBadges();
      setState(() {
        _unlockedBadges = badges.map<String>((b) => b['icon_url'] as String).toList();
      });
    } catch (e) {}
  }

  Widget buildStatItem(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget buildBadgeCollection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/badge-collections'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home_badge_collections_title'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            backgroundImage: index < _unlockedBadges.length
                                ? AssetImage(_unlockedBadges[index])
                                : const AssetImage('assets/icons/lock.jpg'),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBlueButton({
    required BuildContext context,
    required String text,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF111A43),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: AppDrawer(
        userName: _displayName ?? widget.userName,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Row(
                  children: [
                    Text(
                      'home_greeting'.tr(
                        args: [
                          ((_displayName ?? widget.userName).length > 9)
                              ? '${(_displayName ?? widget.userName).substring(0, 9)}...'
                              : (_displayName ?? widget.userName)
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: _isPremiumUser
                            ? colorScheme.onBackground
                            : Colors.grey.withOpacity(0.35),
                      ),
                      onPressed: () {
                        if (_isPremiumUser) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SquatPoseScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BuyPremiumScreen()),
                          );
                        }
                      },
                    ),
                    const Spacer(),
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu, color: colorScheme.onBackground),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'home_search_hint'.tr(),
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(Icons.search, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ExerciseStatsCard(
                currentSteps: _currentSteps,
                maxSteps: maxSteps,
                caloriesBurned: double.parse(caloriesBurned.toStringAsFixed(1)),
                xpEarned: xpEarned,
                onGaugeTap: () {
                  Navigator.pushNamed(context, '/dailySummary');
                },
              ),
              const SizedBox(height: 20),
              buildBadgeCollection(context),
              const SizedBox(height: 12),
              buildBlueButton(
                context: context,
                text: "home_quest_button".tr(),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => QuestScreen()));
                },
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ),
              buildBlueButton(
                context: context,
                text: "home_reminder_button".tr(),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final lastTime = prefs.getString('reminder_time');
                  final lastDays = prefs.getStringList('reminder_days');
                  final result = await ReminderWidget.show(
                    context,
                    initialTime: lastTime,
                    initialDays: lastDays,
                  );
                  if (result != null) {
                    if (result['clear'] == true) {
                      await prefs.remove('reminder_time');
                      await prefs.remove('reminder_days');
                      await NotificationService.cancelAllReminders();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('home_reminder_cleared'.tr())),
                      );
                      return;
                    }
                    final timeString = result['time'] as String;
                    final repeatDays = result['repeat'] as List<String>;
                    String fixedTimeString = timeString.replaceAll('.', ':');
                    final timeParts = fixedTimeString.split(RegExp(r'[: ]'));
                    int hour = int.parse(timeParts[0]);
                    int minute = int.parse(timeParts[1]);
                    bool isPM = timeString.toUpperCase().contains('PM');
                    bool isAM = timeString.toUpperCase().contains('AM');
                    if ((isPM || isAM) && hour > 12) hour = hour % 12;
                    if (isPM && hour < 12) hour += 12;
                    if (isAM && hour == 12) hour = 0;
                    final daysOfWeek = repeatDays.map((d) {
                      switch (d) {
                        case "Monday": return 1;
                        case "Tuesday": return 2;
                        case "Wednesday": return 3;
                        case "Thursday": return 4;
                        case "Friday": return 5;
                        case "Saturday": return 6;
                        case "Sunday": return 7;
                        default: return 1;
                      }
                    }).toList();
                    await prefs.setString('reminder_time', timeString);
                    await prefs.setStringList('reminder_days', repeatDays);
                    await NotificationService.scheduleReminder(
                      id: 100,
                      title: "Time to Workout!",
                      body: "Let's hit your daily fitness goal!",
                      time: TimeOfDay(hour: hour, minute: minute),
                      daysOfWeek: daysOfWeek,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder set!')),
                    );
                  }
                },
                trailing: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
              ),
              // Show Challenge Invitations button only for premium users
              if (_isPremiumUser)
                buildBlueButton(
                  context: context,
                  text: "View Challenge Invitations",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChallengeInvitationScreen(
                        ),
                      ),
                    );
                  },
                  trailing: const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 22),
                ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  "home_workout_title".tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 120,
                child: FutureBuilder<List<WorkoutCategory>>(
                  future: _categoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Failed to load categories'));
                    }
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) {
                      return Center(child: Text('No workout categories available'));
                    }
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: categories.map((cat) => WorkoutCardHomeScreen(
                        imagePath: cat.imageUrl,
                        workoutName: cat.categoryName,
                        workoutLevel: '',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutListPage(categoryKey: cat.categoryKey),
                            ),
                          );
                        },
                      )).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isPremiumUser ? 'Challenge/Tournament' : 'Tournament',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: colorScheme.onBackground,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/challenge-list',
                          arguments: {'isPremium': _isPremiumUser},
                        );
                      },
                      child: Text(
                        "home_tournament_view_all".tr(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: FutureBuilder<List<dynamic>>(
                  future: tournamentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                    }
                    final tournaments = snapshot.data ?? [];
                    if (tournaments.isEmpty) {
                      return const Center(child: Text('No tournaments available'));
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: tournaments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final t = tournaments[index];
                        return TournamentWidget(
                          tournamentName: t['title'] ?? '',
                          daysLeft: t['endDate'] ?? '',
                          participants: t['participants'].toString(),
                          cardWidth: 280,
                          onJoin: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Join Tournament'),
                                content: const Text('Are you sure you want to join this tournament?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text('Join'),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            String status = "";
                            try {
                              status = await TournamentService().joinTournament(t['id']);
                            } catch (e) {
                              status = '';
                            }
                            if (status == "joined") {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Joined tournament!')));
                              reloadTournaments();
                            } else if (status == "already_joined") {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('You have already joined this tournament!')));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Could not join tournament.')));
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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