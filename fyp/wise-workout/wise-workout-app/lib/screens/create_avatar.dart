import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_avatarbg.dart';
import 'buypremium_screen.dart';
import 'package:easy_localization/easy_localization.dart';


class CreateAvatarScreen extends StatefulWidget {
  final String username;
  final bool isPremiumUser;
  final String? currentAvatarPath;
  final String? currentBgPath;
  const CreateAvatarScreen({
    Key? key,
    required this.username,
    required this.isPremiumUser,
    this.currentAvatarPath,
    this.currentBgPath,
  }) : super(key: key);

  @override
  State<CreateAvatarScreen> createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<CreateAvatarScreen> {
  static const List<String> avatarPaths = [
    'assets/avatars/free/free1.png',
    'assets/avatars/free/free2.png',
    'assets/avatars/free/free3.png',
    'assets/avatars/premium/premium2.png',
    'assets/avatars/premium/premium3.png',
    'assets/avatars/premium/premium4.png',
    'assets/avatars/premium/premium5.png',
    'assets/avatars/premium/premium6.png',
    'assets/avatars/premium/premium7.png',
  ];

  static const List<String> bgPaths = [
    'assets/background/bg1.jpg',
    'assets/background/bg2.jpg',
    'assets/background/bg3.jpeg',
    'assets/background/bg4.jpg',
    'assets/background/bg5.png',
    'assets/background/bg6.png',
    'assets/background/bg7.png',
    'assets/background/bg8.png',
    'assets/background/bg9.png',
  ];

  late String selectedAvatarPath;
  late String selectedBgPath;

  @override
  void initState() {
    super.initState();
    selectedAvatarPath = widget.currentAvatarPath ?? avatarPaths[0];
    selectedBgPath = widget.currentBgPath ?? bgPaths[0];
  }

  void _editBackground() async {
    if (!widget.isPremiumUser) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BuyPremiumScreen()),
      );
      return;
    }
    final pickedBg = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AvatarBackgroundPickerScreen(
          selectedBgPath: selectedBgPath,
          selectedAvatarPath: selectedAvatarPath,
          isPremiumUser: widget.isPremiumUser,
        ),
      ),
    );
    if (pickedBg != null) {
      setState(() {
        selectedBgPath = pickedBg;
      });
      Navigator.pop(context, {
        'avatar': selectedAvatarPath,
        'background': selectedBgPath,
      });
    }
  }

  void _confirmAvatar() async {
    try {
      final avatarId = _getAvatarIdFromPath(selectedAvatarPath);
      final apiService = ApiService();
      await apiService.setAvatar(avatarId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('avatar_update_success'.tr())),
      );
      Navigator.pop(context, {
        'avatar': selectedAvatarPath,
        'background': selectedBgPath,
      });
    } catch (e) {
      print('Failed to update avatar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('avatar_update_failed'.tr())),
      );
    }
  }

  int _getAvatarIdFromPath(String path) {
    final Map<String, int> avatarMap = {
      'assets/avatars/free/free1.png': 1,
      'assets/avatars/free/free2.png': 2,
      'assets/avatars/free/free3.png': 3,
      'assets/avatars/premium/premium2.png': 4,
      'assets/avatars/premium/premium3.png': 5,
      'assets/avatars/premium/premium4.png': 6,
      'assets/avatars/premium/premium5.png': 7,
      'assets/avatars/premium/premium6.png': 8,
      'assets/avatars/premium/premium7.png': 9,
    };
    return avatarMap[path] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgHighlight = colorScheme.secondary.withOpacity(0.25);
    final lockedOverlay = colorScheme.surface.withOpacity(0.7);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Text(
                      'avatar_title'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    selectedBgPath,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage(selectedAvatarPath),
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '@${widget.username}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.13),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'avatar_title'.tr(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _editBackground,
                          child: Icon(
                            Icons.arrow_forward,
                            color: widget.isPremiumUser
                                ? colorScheme.onSurface
                                : colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: GridView.builder(
                          itemCount: avatarPaths.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                          ),
                          itemBuilder: (context, index) {
                            final path = avatarPaths[index];
                            final isChosen = selectedAvatarPath == path;
                            final isPremium = index >= 3;
                            final locked = isPremium && !widget.isPremiumUser;
                            return GestureDetector(
                              onTap: () {
                                if (locked) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const BuyPremiumScreen()),
                                  );
                                } else {
                                  setState(() {
                                    selectedAvatarPath = path;
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isChosen ? bgHighlight : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isChosen
                                        ? colorScheme.secondary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Image.asset(
                                          path,
                                          width: 65,
                                          height: 65,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, _error, _stack) =>
                                              Icon(Icons.image_not_supported,
                                                  size: 30,
                                                  color: colorScheme.onSurfaceVariant),
                                        ),
                                      ),
                                    ),
                                    if (locked)
                                      Container(
                                        color: lockedOverlay,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.lock_outline,
                                          color: colorScheme.secondary,
                                          size: 30,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 60),
                        textStyle: Theme.of(context)
                            .textTheme
                            .labelLarge, // For consistent button text
                      ),
                      onPressed: _confirmAvatar,
                      child: Text('avatar_confirm_button'.tr(),
                          style: TextStyle(color: colorScheme.onPrimary)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}