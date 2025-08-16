import 'package:flutter/material.dart';

class ReminderWidget extends StatefulWidget {
  final String? initialTime;
  final List<String>? initialDays;
  const ReminderWidget({Key? key, this.initialTime, this.initialDays}) : super(key: key);

  static Future<Map<String, dynamic>?> show(
      BuildContext context, {
        String? initialTime,
        List<String>? initialDays,
      }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ReminderWidget(
        initialTime: initialTime,
        initialDays: initialDays,
      ),
    );
  }

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  final TextEditingController _timeController = TextEditingController();
  final List<String> _dayShortNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> _longNames = [
    "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
  ];
  List<bool> _selected = List.generate(7, (index) => false);
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialTime != null) {
      _timeController.text = widget.initialTime!;
    }
    if (widget.initialDays != null) {
      for (int i = 0; i < 7; i++) {
        _selected[i] = widget.initialDays!.contains(_longNames[i]);
      }
    }
  }

  bool get isEveryday => _selected.every((v) => v);
  bool get isWeekdays =>
      _selected.sublist(1, 6).every((v) => v) &&
          !_selected[0] &&
          !_selected[6];

  void selectEveryday() => setState(() => _selected = List.generate(7, (_) => true));
  void selectNone() => setState(() => _selected = List.generate(7, (_) => false));
  void selectWeekdays() =>
      setState(() => _selected = [false, true, true, true, true, true, false]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final primaryColor = cs.primary;
    final onPrimary = cs.onPrimary;
    final surfaceColor = cs.surface;
    final inputBg = theme.inputDecorationTheme.fillColor ?? cs.surfaceVariant;
    final errorColor = theme.colorScheme.error;
    final hintColor = theme.hintColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 340,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Set Reminder',
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: cs.onSurface),
                        splashRadius: 20,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: errorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    prefixIcon: Icon(Icons.access_time, color: cs.primary),
                    fillColor: inputBg,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                  onTap: () async {
                    TimeOfDay initial = TimeOfDay.now();
                    if (_timeController.text.isNotEmpty) {
                      final timeStr = _timeController.text.toLowerCase().replaceAll(' ', '');
                      final match = RegExp(r'(\d+):(\d+)(am|pm)?').firstMatch(timeStr);
                      if (match != null) {
                        int hour = int.parse(match.group(1)!);
                        int minute = int.parse(match.group(2)!);
                        final ampm = match.group(3);
                        if (ampm == 'pm' && hour < 12) hour += 12;
                        if (ampm == 'am' && hour == 12) hour = 0;
                        initial = TimeOfDay(hour: hour, minute: minute);
                      }
                    }
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: initial,
                    );
                    if (picked != null) {
                      _timeController.text = picked.format(context);
                    }
                  },
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Repeat",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hintColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: [
                    _buildQuickOption(context, "Everyday", isEveryday, selectEveryday),
                    _buildQuickOption(context, "Weekdays", isWeekdays, selectWeekdays),
                    _buildQuickOption(context, "Clear", !_selected.contains(true), selectNone),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: List.generate(7, (index) {
                      final isSelected = _selected[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selected[index] = !_selected[index];
                          });
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected
                              ? primaryColor
                              : inputBg,
                          child: Text(
                            _dayShortNames[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected ? onPrimary : cs.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        if (_timeController.text.isEmpty && !_selected.contains(true)) {
                          _errorMessage = "Please select time and at least one repeat day.";
                        } else if (_timeController.text.isEmpty) {
                          _errorMessage = "Please select a time.";
                        } else if (!_selected.contains(true)) {
                          _errorMessage = "Please select at least one repeat day.";
                        }
                      });
                      if (_errorMessage != null) return;

                      final selectedDays = List.generate(7, (i) => _selected[i] ? _longNames[i] : null)
                          .whereType<String>()
                          .toList();

                      Navigator.of(context).pop({
                        'time': _timeController.text,
                        'repeat': selectedDays,
                      });
                    },
                    child: Text('Save', style: theme.textTheme.labelLarge?.copyWith(fontSize: 17, color: onPrimary)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop({'clear': true});
                    },
                    child: Text('Clear All Reminders', style: theme.textTheme.labelLarge?.copyWith(fontSize: 17, color: primaryColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOption(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final inputBg = theme.inputDecorationTheme.fillColor ?? cs.surfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : inputBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}