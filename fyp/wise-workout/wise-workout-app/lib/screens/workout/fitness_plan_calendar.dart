import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/fitnessai_service.dart';
import 'dart:convert';
import '../workout/exercise_list_from_ai_page.dart';
import '../../services/google_calendar_service.dart';
import '../../services/user_prefs_service.dart';

class CalendarPlanScreen extends StatefulWidget {
  const CalendarPlanScreen({super.key});

  @override
  State<CalendarPlanScreen> createState() => _CalendarPlanScreenState();
}

class _CalendarPlanScreenState extends State<CalendarPlanScreen> {
  final AIFitnessPlanService _aiService = AIFitnessPlanService();
  final _calendarService = GoogleCalendarService();

  bool _loading = true;
  String? _error;

  List<dynamic> _days = [];
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  Map<String, dynamic>? _selectedDayData;
  DateTime? _planStartDate;
  TimeOfDay _preferredStartTime = const TimeOfDay(hour: 7, minute: 0);

  String? _estimationText; // optional insights
  bool _insightsExpanded = false; // inline insights expand/collapse

  @override
  void initState() {
    super.initState();
    _loadPreferredTime();
    _fetchPlan();
  }

  Future<void> _loadPreferredTime() async {
    final t = await UserPrefsService.getWorkoutStartTime();
    if (t != null && t['hour'] != null && t['minute'] != null) {
      setState(() {
        _preferredStartTime = TimeOfDay(hour: t['hour']!, minute: t['minute']!);
      });
    }
  }

  // --------- helpers ---------
  DateTime? _tryParseDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      try { return DateTime.parse(v); } catch (_) {}
    }
    return null;
  }

  dynamic _jsonDecodeSafe(dynamic v) {
    if (v is String && v.trim().isNotEmpty) {
      try { return jsonDecode(v); } catch (_) {}
    }
    return v;
  }

  bool _looksLikePlanList(dynamic v) {
    if (v is! List || v.isEmpty) return false;
    if (v.first is Map && (v.first as Map).containsKey('plan_title')) return true;
    return v.any((e) => e is Map && (e.containsKey('exercises') || e.containsKey('rest') || e.containsKey('day_of_month')));
  }

  Map<String, dynamic> _normalizeExercise(Map<String, dynamic> m) {
    final name = m['name'] ?? m['exerciseName'] ?? '';
    final sets = m['sets'] ?? m['exerciseSets'];
    final reps = m['reps'] ?? m['exerciseReps'];
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'exerciseName': m['exerciseName'] ?? name,
      'exerciseSets': m['exerciseSets'] ?? sets,
      'exerciseReps': m['exerciseReps'] ?? reps,
      'exerciseId': m['exerciseId'] ?? m['exercise_id'],
      'youtubeUrl': m['youtubeUrl'] ?? '',
      'exerciseKey': m['exerciseKey'] ?? '',
      'exerciseLevel': m['exerciseLevel'] ?? '',
      'exerciseWeight': m['exerciseWeight'],
      'exerciseDuration': m['exerciseDuration'],
      'exerciseEquipment': m['exerciseEquipment'] ?? '',
      'caloriesBurntPerRep': m['caloriesBurntPerRep'],
      'exerciseDescription': m['exerciseDescription'] ?? '',
      'exerciseInstructions': m['exerciseInstructions'] ?? '',
    };
  }

  /// SAFE finder — avoids `firstWhere(orElse: () => null)` crash
  Map<String, dynamic>? _planDayFor(DateTime cellDate) {
    for (final d in _days) {
      final date = d is Map ? d['calendar_date'] : null;
      if (date is DateTime && DateUtils.isSameDay(date, cellDate)) {
        return d as Map<String, dynamic>;
      }
    }
    return null;
  }

  String _buildInlineDescription(Map<String, dynamic> day) {
    final buf = StringBuffer();
    final exs = (day['exercises'] as List?) ?? const [];
    if (exs.isNotEmpty) {
      buf.writeln('Exercises:');
      for (final ex in exs) {
        final name = (ex['name'] ?? ex['exerciseName'])?.toString() ?? 'Exercise';
        final sets = (ex['sets'] ?? ex['exerciseSets'])?.toString() ?? '-';
        final reps = (ex['reps'] ?? ex['exerciseReps'])?.toString() ?? '-';
        buf.writeln('• $name — ${sets}×${reps}');
      }
    }
    final notes = day['notes']?.toString();
    if (notes != null && notes.trim().isNotEmpty) {
      if (buf.isNotEmpty) buf.writeln();
      buf.writeln('Notes: $notes');
    }
    return buf.toString().trim();
  }

  // --------- data load ---------
  Future<void> _fetchPlan() async {
    setState(() {
      _loading = true;
      _error = null;
      _days = [];
      _selectedDate = null;
      _selectedDayData = null;
      _estimationText = null;
      _insightsExpanded = false;
    });

    try {
      final res = await _aiService.fetchLatestSavedPlan();
      // Expected common shapes:
      // { plan: [...], estimation_text/estimationText, start_date/created_at }
      // or { days_json: "...", created_at }
      // or plan as JSON string.

      List<dynamic> planList = [];
      DateTime? startDate;

      if (res is Map) {
        _estimationText = (res['estimation_text'] ?? res['estimationText'])?.toString();
        startDate = _tryParseDate(res['start_date']) ?? _tryParseDate(res['created_at']);

        dynamic rawPlan = res['plan'] ?? res['days_json'];
        rawPlan = _jsonDecodeSafe(rawPlan);

        if (rawPlan is List) {
          planList = List<dynamic>.from(rawPlan);
        } else if (rawPlan is Map && rawPlan['plan'] != null) {
          final inner = _jsonDecodeSafe(rawPlan['plan']);
          if (inner is List) planList = List<dynamic>.from(inner);
        }
      }

      if (planList.isEmpty) {
        throw Exception('No saved plan found.');
      }

      // strip title object if present
      if (planList.first is Map && (planList.first as Map).containsKey('plan_title')) {
        planList = planList.sublist(1);
      }

      startDate ??= DateTime.now();

      // normalize
      final normalizedDays = <Map<String, dynamic>>[];
      for (int i = 0; i < planList.length; i++) {
        final raw = Map<String, dynamic>.from(planList[i] as Map);
        final rest = raw['rest'] == true;
        final notes = raw['notes']?.toString();
        final exsRaw = (raw['exercises'] as List?) ?? <dynamic>[];

        final exs = exsRaw
            .whereType<Map>()
            .map((e) => _normalizeExercise(Map<String, dynamic>.from(e)))
            .toList();

        normalizedDays.add({
          'rest': rest,
          if (!rest) 'exercises': exs,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'calendar_date': startDate.add(Duration(days: i)),
        });
      }

      // pick selection
      final today = DateTime.now();
      final todayIdx = normalizedDays.indexWhere(
            (d) => d['calendar_date'] != null && DateUtils.isSameDay(d['calendar_date'], today),
      );

      setState(() {
        _planStartDate = startDate;
        _days = normalizedDays;
        if (todayIdx != -1) {
          _selectedDayData = normalizedDays[todayIdx];
          _selectedDate = normalizedDays[todayIdx]['calendar_date'];
        } else if (normalizedDays.isNotEmpty) {
          _selectedDayData = normalizedDays.first;
          _selectedDate = normalizedDays.first['calendar_date'];
        }
        final base = _selectedDate ?? _planStartDate ?? DateTime.now();
        _currentMonth = DateTime(base.year, base.month);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // --------- UI ----------
  void _onMonthChanged(int direction) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + direction);
    });
  }

  void _onSelectDay(DateTime cellDate) {
    setState(() {
      _selectedDate = cellDate;
      _selectedDayData = _planDayFor(cellDate); // <- safe
    });
  }

  void _showInsightsSheet() {
    final text = _estimationText?.trim();
    if (text == null || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No insights available for this plan.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Icon(Icons.insights, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Plan Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 14.5, height: 1.35, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Inline collapsible insights card
  Widget _buildInlineInsightsCard() {
    final text = _estimationText?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final preview = text.length > 140 ? '${text.substring(0, 140)}…' : text;

    return Card(
      elevation: 2,
      color: Colors.teal.shade50,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Colors.teal),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Plan Insights',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _insightsExpanded = !_insightsExpanded),
                  child: Text(_insightsExpanded ? 'Hide' : 'Show'),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _insightsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(preview, style: const TextStyle(fontSize: 14.5, height: 1.35, color: Colors.black87)),
              ),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(text, style: const TextStyle(fontSize: 14.5, height: 1.35, color: Colors.black87)),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showInsightsSheet,
                icon: const Icon(Icons.open_in_full),
                label: const Text('Open'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final calendarDays = [
      ...List.filled(firstWeekday - 1, null),
      ...List.generate(daysInMonth, (i) => i + 1)
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          if ((_estimationText ?? '').trim().isNotEmpty)
            IconButton(
              icon: const Icon(Icons.insights),
              tooltip: 'Show insights',
              onPressed: _showInsightsSheet,
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loading ? null : _fetchPlan),
          IconButton(icon: const Icon(Icons.schedule), tooltip: 'Set preferred workout time', onPressed: _loadPreferredTime),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Sync this month to Google Calendar',
            onPressed: _loading
                ? null
                : () async {
              try {
                await _calendarService.addVisibleMonth(
                  planDays: _days,
                  visibleMonth: _currentMonth,
                  defaultStartHour: _preferredStartTime.hour,
                  defaultStartMinute: _preferredStartTime.minute,
                  durationMinutesPerDay: 45,
                  timeZone: 'Asia/Singapore',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Synced workouts to Google Calendar.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calendar sync failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          // month header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => _onMonthChanged(-1)),
                Text(
                  DateFormat.yMMMM().format(_currentMonth),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(icon: const Icon(Icons.chevron_right, size: 28), onPressed: () => _onMonthChanged(1)),
              ],
            ),
          ),

          // Inline insights (shows only if _estimationText exists)
          _buildInlineInsightsCard(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                  .map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(fontWeight: FontWeight.bold)))))
                  .toList(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, mainAxisSpacing: 12, crossAxisSpacing: 8,
                ),
                itemCount: calendarDays.length,
                itemBuilder: (context, index) {
                  final dayNum = calendarDays[index];
                  final cellDate = dayNum == null
                      ? null
                      : DateTime(_currentMonth.year, _currentMonth.month, dayNum);

                  final planDay = cellDate == null ? null : _planDayFor(cellDate);

                  final isSelected = cellDate != null &&
                      _selectedDate != null &&
                      DateUtils.isSameDay(cellDate, _selectedDate!);
                  final isRestDay = planDay?['rest'] == true;
                  final isPastDate = cellDate != null &&
                      cellDate.isBefore(
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                      );

                  return dayNum == null
                      ? const SizedBox.shrink()
                      : GestureDetector(
                    onTap: planDay != null ? () => _onSelectDay(cellDate!) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7B2FF2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF7B2FF2), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$dayNum",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : planDay == null
                                    ? Colors.grey[350]
                                    : isPastDate
                                    ? Colors.grey
                                    : isRestDay
                                    ? Colors.blueGrey
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (planDay != null && isRestDay)
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.hotel, size: 13, color: Colors.blueGrey),
                              ),
                            if (planDay != null && !isRestDay)
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.fitness_center, size: 13, color: Colors.teal),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: _selectedDayData == null
                ? const Center(child: Text("No activities selected."))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((_selectedDayData?['rest'] != true) &&
                    ((_selectedDayData?['exercises'] as List?)?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event_available),
                      label: Text('Add ${_preferredStartTime.format(context)} to Calendar'),
                      onPressed: () async {
                        try {
                          final day = _selectedDayData!;
                          final date = day['calendar_date'] as DateTime?;
                          if (date == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid date for this day.')),
                            );
                            return;
                          }

                          final start = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            _preferredStartTime.hour,
                            _preferredStartTime.minute,
                          );

                          final title = 'Workout Day ${_days.indexOf(day) + 1}';
                          final description = _buildInlineDescription(day);

                          await _calendarService.addEvent(
                            summary: title,
                            start: start,
                            durationMinutes: 45,
                            timeZone: 'Asia/Singapore',
                            description: description,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Day added to Google Calendar.')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                if (_selectedDayData != null && _selectedDate != null)
                  Text(
                    "Activities for Day ${_days.indexOf(_selectedDayData!) + 1} (${DateFormat('MMMM d').format(_selectedDate!)})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                const SizedBox(height: 6),
                if (_selectedDayData?['rest'] == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _selectedDayData?['notes'] ?? "Rest and recover.",
                      style: TextStyle(color: Colors.blueGrey[700], fontSize: 15),
                    ),
                  )
                else if ((_selectedDayData?['exercises'] as List?)?.isNotEmpty ?? false) ...[
                  ...(_selectedDayData!['exercises'] as List).map((ex) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "${ex['name'] ?? ex['exerciseName']} "
                          "(${ex['sets'] ?? ex['exerciseSets']} sets x ${ex['reps'] ?? ex['exerciseReps']} reps)",
                      style: const TextStyle(fontSize: 15),
                    ),
                  )),
                  if ((_selectedDayData!['exercises'] as List).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text('View Exercise Details'),
                        onPressed: () {
                          final exerciseNames = (_selectedDayData!['exercises'] as List)
                              .map<String>((ex) => (ex['name'] ?? ex['exerciseName']) as String)
                              .toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseListFromAIPage(
                                exerciseNames: exerciseNames,
                                dayLabel: "Day ${_days.indexOf(_selectedDayData!) + 1} Exercises",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_selectedDayData?['notes'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _selectedDayData?['notes'],
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("No activities for this day."),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
