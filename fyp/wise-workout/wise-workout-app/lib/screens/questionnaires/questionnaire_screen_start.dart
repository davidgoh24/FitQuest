import 'package:flutter/material.dart';
import 'dart:async';
import 'questionnaire_screen_dob.dart';

class SplashAndOnboardingWrapper extends StatefulWidget {
  const SplashAndOnboardingWrapper({super.key});
  @override
  State<SplashAndOnboardingWrapper> createState() => _SplashAndOnboardingWrapperState();
}

class _SplashAndOnboardingWrapperState extends State<SplashAndOnboardingWrapper> {
  bool showOnboarding = false;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      setState(() {
        showOnboarding = true;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return showOnboarding ? const OnboardingScreen() : const SplashScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'WELCOME TO',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Image.asset(
              'assets/icons/fitquest-icon.png',
              height: 300,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 60, color: scheme.secondary),
                const SizedBox(height: 20),
                Text(
                  "We’re excited to have you on board!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Let’s begin with a few questions to customize your experience and support your fitness goals!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionnaireDobScreen(step: 1, responses: {}),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      "Let's Get Started!",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}