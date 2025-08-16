import 'package:flutter/material.dart';

void showRestTimerDialog(BuildContext context, {int startSeconds = 30}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return RestTimerDialog(startSeconds: startSeconds);
    },
  );
}

class RestTimerDialog extends StatefulWidget {
  final int startSeconds;

  const RestTimerDialog({super.key, required this.startSeconds});

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  late int seconds;

  @override
  void initState() {
    super.initState();
    seconds = widget.startSeconds;
    _startCountdown();
  }

  void _startCountdown() async {
    while (seconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) break;
      setState(() => seconds--);
    }
    if (mounted && seconds == 0) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rest Timer'),
      content: Text(
        '$seconds seconds remaining',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
