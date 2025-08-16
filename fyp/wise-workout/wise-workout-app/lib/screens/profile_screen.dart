import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_avatar.dart';
import 'editprofile_screen.dart';
import 'privacypolicy_screen.dart';
import 'feedback_screen.dart';
import '../services/api_service.dart';
import '../services/badge_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/profile_avatar_section.dart';
import '../widgets/profile_badge_collection.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_lucky_spin_card.dart';
import '../widgets/profile_menu_list.dart';
import '../themes/theme_notifier.dart';
import '../services/fitnessai_service.dart';
import '../screens/edit_preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final int xp;
  final String? profileImagePath;
  final String? profileBgPath;
  final bool isPremiumUser;
  ProfileScreen({
    Key? key,
    required this.userName,
    this.profileImagePath,
    this.profileBgPath,
    this.xp = 123,
    this.isPremiumUser = false,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String? _profileImagePath;
  late String? _profileBgPath;
  late String _userName;
  late String? _dob;
  late bool _isPremiumUser;
  int _tokens = 23;
  final ApiService apiService = ApiService();
  final BadgeService _badgeService = BadgeService();
  Map<String, dynamic> _profileData = {};
  List<String> _unlockedBadgeIcons = [];
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _selectedLanguageCode = 'en';
  int _level = 1;
  int _progressInLevel = 0;
  int _xpForThisLevel = 100;
  int _totalXP = 0;
  bool _busy = false;
  Map<String, dynamic>? _preferences;
  List<dynamic>? _plan;
  String? _estimationText;
  final _aiService = AIFitnessPlanService();

  @override
  void initState() {
    super.initState();
    _profileImagePath = widget.profileImagePath;
    _profileBgPath = widget.profileBgPath ?? 'assets/background/black.jpg';
    _isPremiumUser = widget.isPremiumUser;
    _userName = widget.userName;
    _loadProfile();
    _loadUserBadges();
    _loadLanguagePreference();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await apiService.getCurrentProfile();
      if (!mounted) return;
      setState(() {
        _profileData = profile;
        _isPremiumUser = profile['role'] == 'premium';
        _profileImagePath = profile['avatar'];
        _profileBgPath = profile['background'] ?? 'assets/background/black.jpg';
        _userName = profile['username'] ?? widget.userName;
        _dob = profile['dob'];
        _tokens = profile['tokens'] ?? 0;
        _level = profile['level'] ?? 1;
        _progressInLevel = profile['progressInLevel'] ?? 0;
        _xpForThisLevel = profile['xpForThisLevel'] ?? 100;
        _totalXP = profile['totalXP'] ?? 0;
      });
    } catch (e) {}
  }

  Future<void> _loadUserBadges() async {
    try {
      final badges = await _badgeService.getUserBadges();
      if (!mounted) return;
      setState(() {
        _unlockedBadgeIcons = badges.map<String>((b) => b['icon_url'] as String).toList();
      });
    } catch (e) {}
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final langCode = await apiService.getLanguage();
      if (!mounted) return;
      context.setLocale(Locale(langCode));
      setState(() {
        _selectedLanguageCode = langCode;
      });
    } catch (err) {
      context.setLocale(const Locale('en'));
      setState(() {
        _selectedLanguageCode = 'en';
      });
    }
  }


  String _languageNameFromCode(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      case 'zh':
        return 'Chinese';
      case 'ms':
        return 'Malay';
      default:
        return 'English';
    }
  }

  String _themeNameFromMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.normal:
        return tr('appearance_theme_normal');
      case AppThemeMode.dark:
        return tr('appearance_theme_dark');
      case AppThemeMode.christmas:
        return tr('appearance_theme_christmas');
      default:
        return tr('appearance_theme_normal');
    }
  }

  void _showAvatarPopup(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_profileBgPath != null)
                    ClipOval(
                      child: _profileBgPath!.startsWith('http')
                          ? Image.network(_profileBgPath!,
                          width: 220, height: 220, fit: BoxFit.cover)
                          : Image.asset(_profileBgPath!,
                          width: 220, height: 220, fit: BoxFit.cover),
                    ),
                  if (_profileImagePath != null && _profileImagePath!.isNotEmpty)
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: _profileImagePath!.startsWith('http')
                          ? NetworkImage(_profileImagePath!)
                          : AssetImage(_profileImagePath!) as ImageProvider<Object>,
                      backgroundColor: Colors.transparent,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(_userName, style: Theme.of(context).textTheme.titleLarge),
              if (_isPremiumUser)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '🌟 Premium User 🌟',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String actionId,
      {String? subtitle, VoidCallback? onTap}) {
    VoidCallback? handleTap = onTap;
    if (handleTap == null) {
      switch (actionId) {
        case "avatar":
          handleTap = () async {
            final result = await Navigator.push<Map<String, String?>>(
              context,
              MaterialPageRoute(
                builder: (_) => CreateAvatarScreen(
                  username: _userName,
                  isPremiumUser: _isPremiumUser,
                  currentAvatarPath: _profileImagePath,
                  currentBgPath: _profileBgPath,
                ),
              ),
            );
            if (result != null) {
              setState(() {
                _profileImagePath = result['avatar'];
                _profileBgPath = result['background'];
              });
            }
          };
          break;
        case "profile":
          handleTap = () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  firstName: _profileData['firstName'] ?? '',
                  lastName: _profileData['lastName'] ?? '',
                  username: _profileData['username'] ?? '',
                  dob: _profileData['dob'] ?? '',
                  email: _profileData['email'] ?? '',
                  level: "Beginner",
                  accountType: _profileData['role'] ?? 'user',
                  profileImage: _profileImagePath ?? '',
                  backgroundImage: _profileBgPath ?? 'assets/background/black.jpg',
                ),
              ),
            );
            if (result != null) {
              _loadProfile();
            }
          };
          break;
        case "preferences":
          handleTap = () async {
            if (_busy) return;
            setState(() => _busy = true);
            try {
              // 1) Fetch latest prefs
              final prefs = await _aiService.fetchPreferencesOnly();
              if (!mounted) return;

              // 2) Navigate to editor with the freshest data
              final updatedPrefs = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPreferencesScreen(
                    preferences: Map<String, dynamic>.from(prefs ?? {}),
                  ),
                ),
              );

              // 3) Apply updates if user saved
              if (updatedPrefs != null && mounted) {
                setState(() {
                  _preferences = Map<String, dynamic>.from(updatedPrefs);
                  _plan = null;            // clear cached plan so it regenerates
                  _estimationText = null;  // clear any derived text
                });
              }
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load preferences: $e')),
              );
            } finally {
              if (mounted) setState(() => _busy = false);
            }
          };
          break;
        case "password":
          handleTap = () => Navigator.pushNamed(context, '/change-password');
          break;
        case "calendar":
          handleTap = () => Navigator.pushNamed(context, '/calendar-sync');
        break;
        case "wearable":
          handleTap = () => Navigator.pushNamed(context, '/wearable-screen');
          break;
        case "workout_history":
          handleTap = () => Navigator.pushNamed(context, '/workout-history');
          break;
        case "workout_plan":
          handleTap = () => Navigator.pushNamed(context, '/workout-plans-screen');
          break;
        case "premium_plan":
          handleTap = () => Navigator.pushNamed(context, '/premium-plan');
          break;
        case "language":
          handleTap = () async {
            await Navigator.pushNamed(context, '/language-settings');
            _loadLanguagePreference();
          };
          break;
        case "privacy_policy":
          handleTap = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
          );
          break;
        case "appearance":
          handleTap = () => Navigator.pushNamed(context, '/appearance-settings');
          break;
        case "feedback":
          handleTap = () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            );
          };
          break;
        default:
          break;
      }
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: actionId == "feedback"
    ? Text(
        tr('profile_feedback'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      )
    : Text(
        tr('profile_$actionId'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: Theme.of(context).iconTheme.color),
      onTap: handleTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currentThemeMode = themeNotifier.appThemeMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileAvatarSection(
                profileImg: _profileImagePath,
                profileBg: _profileBgPath,
                username: _userName,
                isPremiumUser: _isPremiumUser,
                onAvatarTap: () => _showAvatarPopup(context),
              ),
              const SizedBox(height: 20),
              ProfileBadgeCollection(unlockedBadges: _unlockedBadgeIcons),
              const SizedBox(height: 20),
              ProfileInfoRow(
                xp: "$_totalXP XP",
                level: "Level $_level",
                progressInLevel: _progressInLevel,
                xpForThisLevel: _xpForThisLevel,
              ),
              const SizedBox(height: 20),
              ProfileLuckySpinCard(
                tokens: _tokens,
                onSpinComplete: (newTokens) => setState(() {
                  _tokens = newTokens;
                }),
              ),
              const SizedBox(height: 20),
              ProfileMenuList(
                isPremiumUser: _isPremiumUser,
                menuItems: [
                  _profileItem(Icons.person, "avatar"),
                  _profileItem(Icons.settings, "profile", subtitle: tr('profile_profile_subtitle')),
                  _profileItem(Icons.edit_attributes, "preferences"),
                  _profileItem(Icons.lock, "password"),
                  _profileItem(Icons.watch, "wearable",),
                  _profileItem(Icons.calendar_month_rounded, "calendar"),
                  _profileItem(Icons.fitness_center, "workout_plan"),
                  _profileItem(Icons.history, "workout_history"),
                  if (!_isPremiumUser)
                    _profileItem(Icons.workspace_premium, "premium_plan"),
                  _profileItem(Icons.language, "language", subtitle: _languageNameFromCode(_selectedLanguageCode)),
                  _profileItem(Icons.privacy_tip, "privacy_policy"),
                  _profileItem(Icons.palette, "appearance", subtitle: _themeNameFromMode(currentThemeMode)),
                  _profileItem(Icons.star, "feedback"),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/leaderboard');
              break;
            case 2:
              Navigator.pushNamed(context, '/workout-dashboard');
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