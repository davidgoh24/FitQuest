import 'package:flutter/material.dart';
import '../../services/questionnaire_service.dart';

class QuestionnaireScreen9 extends StatelessWidget {
  final int step;
  final int totalSteps;
  final Map<String, dynamic> responses;
  const QuestionnaireScreen9({
    super.key,
    required this.step,
    this.totalSteps = 9,
    required this.responses,
  });

  double get bmiValue {
    final heightCm = responses['height_cm'];
    final weightKg = responses['weight_kg'];
    final h = double.tryParse(heightCm?.toString() ?? '');
    final w = double.tryParse(weightKg?.toString() ?? '');
    if (h != null && w != null && h > 0) {
      return double.parse((w / ((h / 100) * (h / 100))).toStringAsFixed(1));
    }
    return 0.0;
  }

  String get bmiCategory {
    final bmi = bmiValue;
    final gender = (responses['gender'] ?? '').toString().toLowerCase();
    if (bmi == 0) return '';
    if (gender == 'female') {
      if (bmi < 18.0) return "Underweight (Female)";
      if (bmi < 24.0) return "Normal (Female)";
      if (bmi < 29.0) return "Overweight (Female)";
      return "Obese (Female)";
    } else {
      if (bmi < 18.5) return "Underweight (Male)";
      if (bmi < 25.0) return "Normal (Male)";
      if (bmi < 30.0) return "Overweight (Male)";
      return "Obese (Male)";
    }
  }

  void handleSubmit(BuildContext context) async {
    final Map<String, dynamic> payload = Map.from(responses);
    payload['bmi_value'] = bmiValue;
    print('Questionnaire Submit Payload: $payload');
    await QuestionnaireService.submitPreferences(payload);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color ?? colorScheme.onSurface, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Icon(Icons.fitness_center, color: colorScheme.secondary, size: 28),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Text(
                        "Result",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 19,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Your BMI is",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                          color: theme.textTheme.titleLarge?.color ?? colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // BMI Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Column(
                          children: [
                            Text(
                              bmiValue == 0 ? '-' : bmiValue.toStringAsFixed(1),
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 44,
                                color: colorScheme.onSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bmiCategory,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 54),
                      SizedBox(
                        width: 140,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: () => handleSubmit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          child: const Text("Done"),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}