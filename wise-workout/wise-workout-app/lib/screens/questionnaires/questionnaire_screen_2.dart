import 'package:flutter/material.dart';
import 'questionnaire_screen_3.dart';

class QuestionnaireScreen2 extends StatefulWidget {
  final int step;
  final int totalSteps;
  final Map<String, dynamic> responses;
  const QuestionnaireScreen2({
    super.key,
    required this.step,
    this.totalSteps = 9,
    required this.responses,
  });
  @override
  State<QuestionnaireScreen2> createState() => _QuestionnaireScreen2State();
}

class _QuestionnaireScreen2State extends State<QuestionnaireScreen2> {
  int selectedIndex = -1;
  final List<String> options = [
    'Never',
    '1-2 times a week',
    '3-4 times a week',
    '5-6 times a week',
    'Daily',
  ];

  @override
  void initState() {
    super.initState();
    final previous = widget.responses['workout_days'];
    if (previous != null) {
      final idx = options.indexOf(previous);
      if (idx != -1) selectedIndex = idx;
    }
  }

  void handleNext() {
    if (selectedIndex != -1) {
      widget.responses['workout_days'] = options[selectedIndex];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionnaireScreen3(
            step: widget.step + 1,
            totalSteps: widget.totalSteps,
            responses: widget.responses,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool buttonEnabled = selectedIndex != -1;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: theme.iconTheme.color ?? Colors.black, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Icon(Icons.fitness_center,
                      color: colorScheme.secondary,
                      size: 28),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 38),
                      Text(
                        "Question ${widget.step} out of ${widget.totalSteps}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          "How many days a week\ncan you commit to working out?",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 21,
                            color: theme.textTheme.titleLarge?.color,
                            height: 1.19,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 23),
                      ...List.generate(options.length, (i) {
                        final selected = selectedIndex == i;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 0),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: MediaQuery.of(context).size.width * 0.94,
                              height: 54,
                              decoration: BoxDecoration(
                                color: selected
                                    ? colorScheme.secondary
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(27),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                                child: Text(
                                  options[i],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 15.5,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    letterSpacing: 0.08,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 28),
                      // Next button
                      SizedBox(
                        width: 140,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: buttonEnabled ? handleNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonEnabled
                                ? colorScheme.primary // darkBlue
                                : colorScheme.onSurface.withOpacity(0.12),
                            foregroundColor: buttonEnabled
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
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
                          child: const Text("Next"),
                        ),
                      ),
                      const SizedBox(height: 18),
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