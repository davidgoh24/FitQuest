import 'package:flutter/material.dart';

class bottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? workoutIcon;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color backgroundColor;
  final bool isRegistered; // <-- New parameter

  const bottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isRegistered = true, // <-- Pass from screen
    this.workoutIcon,
    this.selectedItemColor = Colors.amber,
    this.unselectedItemColor = Colors.black54,
    this.backgroundColor = Colors.white,
  });

  static const double _iconSize = 24;

  static Widget _imageIcon(String assetName) {
    return Image.asset(
      'assets/icons/$assetName',
      height: _iconSize,
      fit: BoxFit.contain,
    );
  }

  static final Widget _homeIcon = _imageIcon('Home.png');
  static final Widget _leaderboardIcon = _imageIcon('Leaderboard.png');
  static final Widget _messagesIcon = _imageIcon('Messages.png');
  static final Widget _profileIcon = _imageIcon('Profile.png');

  void _showRegisterPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF1E1E2E), // Dark background
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Register Required",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You need to register to access this feature.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushNamed(context, '/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (!isRegistered) {
      _showRegisterPrompt(context);
    } else {
      onTap(index);
    }
  }

  void _handleWorkoutTap(BuildContext context) {
    if (!isRegistered) {
      _showRegisterPrompt(context);
    } else {
      Navigator.pushNamed(context, '/workout-category-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        BottomNavigationBar(
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          backgroundColor: backgroundColor,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (index) => _handleTap(context, index),
          items: [
            BottomNavigationBarItem(icon: _homeIcon, label: 'Home'),
            BottomNavigationBarItem(icon: _leaderboardIcon, label: 'Leader board'),
            const BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
            BottomNavigationBarItem(icon: _messagesIcon, label: 'Messages'),
            BottomNavigationBarItem(icon: _profileIcon, label: 'Profile'),
          ],
        ),
        Positioned(
          bottom: 10,
          child: GestureDetector(
            onTap: () => _handleWorkoutTap(context),
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: selectedItemColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: workoutIcon ??
                    const Icon(Icons.fitness_center, size: 36, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}