import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleLoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(
              'assets/icons/google-icon.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Transform.translate(
            offset: const Offset(9, 0),
            child: const Text(
              "Sign in with Google",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
