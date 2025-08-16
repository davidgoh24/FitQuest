import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class GiveFeedbackScreen extends StatefulWidget {
  const GiveFeedbackScreen({super.key});
  @override
  State<GiveFeedbackScreen> createState() => _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends State<GiveFeedbackScreen> {
  int rating = 0;
  final Set<String> selectedLikes = {};
  final Set<String> selectedWrongs = {};
  final TextEditingController notesController = TextEditingController();

  static const likesOptions = [
    "Convenience",
    "Reward System",
    "UI/UX",
    "AI Integrated Support",
    "Challenges/Tournament",
    "Others",
  ];

  static const wrongOptions = [
    "Application bugs",
    "Slow loading",
    "Unclear instruction",
    "Other Problems",
  ];

  static const Color primaryYellow = Color(0xFFFFC224);
  static const Color highlightPurple = Color(0xFFA089E7);

  bool loading = false;

  void toggleSelection(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Thank You!"),
        content: const Text(
          "Your feedback has been submitted successfully.",
        ),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Whoops!"),
        content: Text(message),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _onSubmit() async {
    final hasLikes = selectedLikes.isNotEmpty;
    final hasWrongs = selectedWrongs.isNotEmpty;
    final hasNotes = notesController.text.trim().isNotEmpty;

    if (rating == 0) {
      if (!mounted) return;
      _showErrorDialog("Please select your rating.");
      return;
    }
    if (!hasLikes && !hasWrongs && !hasNotes) {
      if (!mounted) return;
      _showErrorDialog("Please select at least one thing you like/dislike or enter your notes.");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FeedbackService().submitFeedback(
        rating: rating,
        message: hasNotes ? notesController.text.trim() : null,
        likedFeatures: selectedLikes.toList(),
        problems: selectedWrongs.toList(),
      );
      if (!mounted) return;
      await _showSuccessDialog();
      return;
    } catch (_) {
      if (!mounted) return;
      _showErrorDialog("Failed to submit feedback. Please try again.");
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clr = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: clr.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: clr.onBackground),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 2),
                Text(
                  "How was your overall experience?",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "It will help us to serve you better.",
                  style: textTheme.bodyMedium?.copyWith(
                    color: clr.onBackground.withOpacity(0.62),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            color: primaryYellow,
                            size: 38,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  "What do you like from FitQuest?",
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: clr.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: likesOptions.map((opt) {
                    final selected = selectedLikes.contains(opt);
                    return ChoiceChip(
                      label: Text(
                        opt,
                        style: textTheme.labelLarge?.copyWith(
                          color: selected ? clr.onPrimary : clr.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: selected,
                      selectedColor: primaryYellow,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: selected ? primaryYellow : clr.outline.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onSelected: (_) => toggleSelection(selectedLikes, opt),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  "Anything wrong?",
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: clr.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: wrongOptions.map((opt) {
                    final selected = selectedWrongs.contains(opt);
                    return ChoiceChip(
                      label: Text(
                        opt,
                        style: textTheme.labelLarge?.copyWith(
                          color: selected ? clr.onPrimary : clr.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: selected,
                      selectedColor: highlightPurple,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: selected ? highlightPurple : clr.outline.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onSelected: (_) => toggleSelection(selectedWrongs, opt),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  "Notes",
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: clr.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: "Tell us more about your experience. (max. 200 words)",
                    filled: true,
                    fillColor: clr.surfaceVariant,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: clr.outline.withOpacity(0.2),
                        width: 1.2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: clr.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  style: textTheme.bodyMedium?.copyWith(color: clr.onSurface, fontSize: 15),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellow,
                      foregroundColor: clr.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: loading ? null : _onSubmit,
                    child: loading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            "Submit Feedback",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: clr.onPrimary,
                              fontSize: 16,
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
