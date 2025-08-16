import 'package:flutter/material.dart';

class ProfileMenuList extends StatelessWidget {
  final bool isPremiumUser;
  final List<Widget> menuItems;

  const ProfileMenuList({
    Key? key,
    required this.isPremiumUser,
    required this.menuItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: menuItems,
      ),
    );
  }
}