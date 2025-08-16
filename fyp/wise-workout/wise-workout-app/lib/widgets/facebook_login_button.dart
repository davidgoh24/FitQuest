import 'package:flutter/material.dart';

class FacebookLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FacebookLoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-4, 0),
            child: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/icons/facebook-icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Sign in with Facebook",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
