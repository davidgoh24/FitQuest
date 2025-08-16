import 'package:flutter/material.dart';

class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        // TODO: Implement Apple login
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-4, 0),
            child: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/icons/apple-icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Sign in with Apple",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
