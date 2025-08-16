import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'questionnaire_screen_2.dart';

class QuestionnaireScreen extends StatefulWidget {
  final int step;
  final int totalSteps;
  final Map<String, dynamic> responses;

  const QuestionnaireScreen({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.responses,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int selectedHeight = 170;
  int selectedWeight = 60;

  @override
  void initState() {
    super.initState();
    selectedHeight = int.tryParse(widget.responses['height_cm'] ?? '') ?? 170;
    selectedWeight = int.tryParse(widget.responses['weight_kg'] ?? '') ?? 60;
  }

  void handleNext() {
    widget.responses['height_cm'] = selectedHeight.toString();
    widget.responses['weight_kg'] = selectedWeight.toString();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireScreen2(
          step: widget.step + 1,
          totalSteps: widget.totalSteps,
          responses: widget.responses,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: scheme.onBackground),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Icon(Icons.fitness_center, color: scheme.secondary, size: 34),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        "Question ${widget.step} out of ${widget.totalSteps}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "What's your height?",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onBackground,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 250,
                        height: 120,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shadow.withOpacity(0.055),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: selectedHeight - 100),
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHeight = 100 + index;
                            });
                          },
                          children: List.generate(151, (index) {
                            final value = 100 + index;
                            return Center(
                              child: Text(
                                "$value cm",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        "What's your weight?",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onBackground,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 250,
                        height: 120,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shadow.withOpacity(0.055),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: selectedWeight - 30),
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedWeight = 30 + index;
                            });
                          },
                          children: List.generate(171, (index) {
                            final value = 30 + index;
                            return Center(
                              child: Text(
                                "$value kg",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 38),
                      SizedBox(
                        width: 160,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: const Text("Next"),
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
