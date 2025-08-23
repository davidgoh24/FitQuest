import 'package:flutter/material.dart';

class WeekPickerDialog extends StatefulWidget {
  final DateTimeRange? initialRange;
  const WeekPickerDialog({super.key, this.initialRange});

  @override
  State<WeekPickerDialog> createState() => _WeekPickerDialogState();
}

class _WeekPickerDialogState extends State<WeekPickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialRange != null) {
      _startDate = widget.initialRange!.start;
      _endDate = widget.initialRange!.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Week",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                        _endDate = picked.add(const Duration(days: 6));
                      });
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        "Start Date",
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        _startDate != null
                            ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                            : "Pick Date",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.arrow_forward, color: colorScheme.onSurfaceVariant),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "End Date",
                      style: textTheme.bodyMedium,
                    ),
                    Text(
                      _endDate != null
                          ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
                          : "-",
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (_startDate != null)
                ? () => Navigator.pop(
                context, DateTimeRange(start: _startDate!, end: _endDate!))
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Confirm",
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}