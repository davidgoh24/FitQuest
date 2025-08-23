import 'package:flutter/material.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String? profileImg;
  final String? profileBg;
  final String username;
  final bool isPremiumUser;
  final VoidCallback onAvatarTap;

  const ProfileAvatarSection({
    Key? key,
    this.profileImg,
    this.profileBg,
    required this.username,
    required this.isPremiumUser,
    required this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: profileBg != null && profileBg!.startsWith('http')
                  ? Image.network(profileBg!, width: 120, height: 120, fit: BoxFit.cover)
                  : Image.asset(profileBg!, width: 120, height: 120, fit: BoxFit.cover),
            ),
            GestureDetector(
              onTap: onAvatarTap,
              child: (profileImg != null && profileImg!.isNotEmpty)
                  ? CircleAvatar(
                radius: 54,
                backgroundImage: profileImg!.startsWith("http")
                    ? NetworkImage(profileImg!)
                    : AssetImage(profileImg!) as ImageProvider<Object>,
                backgroundColor: Colors.transparent,
              )
                  : const SizedBox(width: 108, height: 108),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Hi, $username!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (isPremiumUser)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('🌟 Premium User 🌟', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
      ],
    );
  }
}