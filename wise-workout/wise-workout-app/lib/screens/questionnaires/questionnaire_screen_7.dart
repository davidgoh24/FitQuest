import 'package:flutter/material.dart';
import 'questionnaire_screen_8.dart';

class QuestionnaireScreen7 extends StatefulWidget {
  final int step;
  final int totalSteps;
  final Map<String, dynamic> responses;
  const QuestionnaireScreen7({
    super.key,
    required this.step,
    this.totalSteps = 9,
    required this.responses,
  });
  @override
  State<QuestionnaireScreen7> createState() => _QuestionnaireScreen7State();
}

class _QuestionnaireScreen7State extends State<QuestionnaireScreen7> {
  int selectedIndex = -1;
  final List<String> options = [
    'Abs/Core',
    'Elbow',
    'Wrist',
    'Knees',
    'Shoulder',
    'No Injury',
    'Others (Type here)',
  ];
  final TextEditingController othersController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final previous = widget.responses['injury'];
    if (previous != null) {
      final idx = options.indexOf(previous);
      if (idx != -1) {
        selectedIndex = idx;
      } else {
        selectedIndex = options.length - 1;
        othersController.text = previous;
      }
    }
  }
  @override
  void dispose() {
    othersController.dispose();
    super.dispose();
  }
  void handleNext() {
    String selectedValue;
    if (selectedIndex == options.length - 1) {
      // Others selected
      selectedValue = othersController.text;
    } else {
      selectedValue = options[selectedIndex];
    }
    widget.responses['injury'] = selectedValue;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireScreen8(
          step: widget.step + 1,
          totalSteps: widget.totalSteps,
          responses: widget.responses,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    bool othersSelected = selectedIndex == options.length - 1;
    bool buttonEnabled = (selectedIndex != -1 && (!othersSelected || othersController.text.trim().isNotEmpty));

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.iconTheme.color ?? colorScheme.onSurface,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Icon(
                    Icons.fitness_center,
                    color: colorScheme.secondary,
                    size: 28,
                  ),
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
                          "Do you have any injuries\nor limitations we should consider?",
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
                      // Options
                      ...List.generate(options.length, (i) {
                        final selected = selectedIndex == i;
                        final isOthers = i == options.length - 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = i;
                                if (!isOthers) {
                                  othersController.clear();
                                }
                              });
                            },
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
                                  )
                                ],
                              ),
                              alignment: Alignment.centerLeft,
                              child: isOthers
                                  ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                                child: TextField(
                                  enabled: selected,
                                  controller: othersController,
                                  onChanged: (_) => setState(() {}),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 15.5,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.08,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Others (Type here)",
                                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.hintColor,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: theme.disabledColor, width: 1),
                                    ),
                                  ),
                                ),
                              )
                                  : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                                child: Text(
                                  options[i],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 15.5,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                                    letterSpacing: 0.08,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 42),
                      SizedBox(
                        width: 140,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: buttonEnabled ? handleNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonEnabled
                                ? colorScheme.primary
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