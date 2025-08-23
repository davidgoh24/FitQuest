import 'package:flutter/material.dart';
import '../../services/exercise_service.dart';
import '../../services/create_workout_plan_service.dart';
import '../../services/create_workout_list_service.dart';

class WorkoutPlansController {
  final CreateWorkoutPlanService planService;
  final CreateWorkoutListService listService;

  WorkoutPlansController({
    required this.planService,
    required this.listService,
  });

  Future<WorkoutPlan> createPlan(String title) async {
    final p = await planService.createPlan(planTitle: title);
    await listService.loadPlans();
    return p;
  }

  Future<void> deletePlan(int planId) async {
    await planService.deletePlan(planId);
    await listService.loadPlans();
  }

  Future<List<WorkoutPlanItem>> getPlanItems(int planId) =>
      planService.getPlanItems(planId);

  /// NEW: add by exerciseId (backend only needs exercise_id now)
  Future<int> addItem({
    required int planId,
    required int exerciseId,
  }) async {
    return planService.addOneItem(planId: planId, exerciseId: exerciseId);
  }

  /// Fetch all exercises for the picker (must include exercise_id)
  Future<List<_ExerciseLite>> fetchAllExercises() async {
    final exerciseService = ExerciseService();
    final exercises = await exerciseService.fetchAllExercises();

    return exercises.map((e) {
      final d = e as dynamic; // adapt to your Exercise model shape
      final id = d.exerciseId ?? d.id ?? d.exercise_id;
      final name = (d.exerciseName ?? d.name ?? d.exercise_name ?? '').toString();
      final level = d.exerciseLevel?.toString();
      final description =
      (d.exerciseDescription ?? d.description ?? d.exercise_description)?.toString();
      return _ExerciseLite(
        id: (id is int) ? id : int.tryParse(id.toString()) ?? 0,
        name: name,
        level: level,
        description: description,
      );
    }).toList();
  }
}

class _ExerciseLite {
  final int id;         // exercise_id
  final String name;
  final String? level;
  final String? description;

  _ExerciseLite({
    required this.id,
    required this.name,
    this.level,
    this.description,
  });

  factory _ExerciseLite.fromJson(Map<String, dynamic> json) {
    final rawId = json['exercise_id'] ?? json['id'] ?? json['exerciseId'];
    final id = (rawId is int) ? rawId : int.tryParse(rawId.toString()) ?? 0;
    return _ExerciseLite(
      id: id,
      name: (json['exercise_name'] ?? json['name'] ?? json['title'] ?? '').toString(),
      level: json['exercise_level']?.toString(),
      description: (json['exercise_description'] ?? json['description'])?.toString(),
    );
  }
}

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  late final CreateWorkoutPlanService _planService;
  late final CreateWorkoutListService _listService;
  late final WorkoutPlansController _controller;

  final _titleCtrl = TextEditingController();
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _planService = CreateWorkoutPlanService();
    _listService = CreateWorkoutListService(service: _planService);
    _controller = WorkoutPlansController(planService: _planService, listService: _listService);

    _listService.addListener(_refresh);
    _listService.loadPlans();
  }

  @override
  void dispose() {
    _listService.removeListener(_refresh);
    _titleCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workout Plans'),
      ),
      body: RefreshIndicator(
        onRefresh: _listService.loadPlans,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCreateCard(colorScheme),
            const SizedBox(height: 16),
            _buildPlansList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateCard(ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create a new plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'Plan title (e.g., Push/Pull/Legs)',
                prefixIcon: const Icon(Icons.edit_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _onCreatePressed(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _creating ? null : _onCreatePressed,
                icon: _creating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_circle_outline),
                label: const Text('Create & Add Exercises'),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a plan, then pick exercises from your library.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    if (_listService.loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_listService.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(child: Text('Error: ${_listService.error}', style: TextStyle(color: Colors.redAccent))),
      );
    }

    final plans = _listService.plans;
    if (plans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 12),
          Expanded(child: Text("No plans yet. Create one above!", style: Theme.of(context).textTheme.bodyMedium)),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your plans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...plans.map((p) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(p.planTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: p.createdAt == null ? null : Text('Created ${p.createdAt}'),
            onTap: () => _openPlanItems(planId: p.planId, title: p.planTitle),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'add') {
                  _openExercisePicker(planId: p.planId, title: p.planTitle);
                } else if (v == 'view') {
                  _openPlanItems(planId: p.planId, title: p.planTitle);
                } else if (v == 'delete') {
                  final ok = await _confirmDelete(p.planTitle);
                  if (ok) {
                    await _controller.deletePlan(p.planId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted "${p.planTitle}"')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'view', child: Text('View items')),
                PopupMenuItem(value: 'add', child: Text('Add exercises')),
                PopupMenuItem(value: 'delete', child: Text('Delete plan')),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _onCreatePressed() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a plan title')));
      return;
    }

    setState(() => _creating = true);
    try {
      final plan = await _controller.createPlan(title);
      if (!mounted) return;
      _titleCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created "${plan.planTitle}"')));
      _openExercisePicker(planId: plan.planId, title: plan.planTitle);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create: $e')));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<bool> _confirmDelete(String planTitle) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete plan?'),
        content: Text('This will remove "$planTitle" and its items.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    ) ?? false;
  }

  Future<void> _openPlanItems({required int planId, required String title}) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PlanItemsSheet(planId: planId, title: title, controller: _controller),
    );
  }

  Future<void> _openExercisePicker({required int planId, required String title}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ExercisePickerSheet(planId: planId, title: title, controller: _controller),
    );
  }
}

class _PlanItemsSheet extends StatefulWidget {
  final int planId;
  final String title;
  final WorkoutPlansController controller;
  const _PlanItemsSheet({required this.planId, required this.title, required this.controller});

  @override
  State<_PlanItemsSheet> createState() => _PlanItemsSheetState();
}

class _PlanItemsSheetState extends State<_PlanItemsSheet> {
  bool _loading = true;
  String? _error;
  List<WorkoutPlanItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _items = await widget.controller.getPlanItems(widget.planId);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercises in "${widget.title}"', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_loading) const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null) Expanded(child: Center(child: Text('Error: $_error')))
            else if (_items.isEmpty) const Expanded(child: Center(child: Text('No items yet')))
              else Expanded(
                  child: ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final it = _items[i];
                      final details = [
                        if (it.exerciseSets != null) 'Sets: ${it.exerciseSets}',
                        if (it.exerciseReps != null) 'Reps: ${it.exerciseReps}',
                        if (it.exerciseDuration != null) 'Sec: ${it.exerciseDuration}',
                      ].join('  •  ');
                      return ListTile(
                        title: Text(it.exerciseName ?? 'Exercise #${it.exerciseId}'),
                        subtitle: details.isEmpty ? null : Text(details),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start workout'),
                    onPressed: _items.isEmpty
                        ? null
                        : () {
                      final exerciseNames = _items
                          .map((e) => e.exerciseName ?? 'Exercise #${e.exerciseId}')
                          .toList();

                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/workout-plan-exercise-list',
                        arguments: {
                          'planTitle': widget.title,
                          'exerciseNames': exerciseNames,
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ExercisePickerSheet extends StatefulWidget {
  final int planId;
  final String title;
  final WorkoutPlansController controller;
  const _ExercisePickerSheet({required this.planId, required this.title, required this.controller});

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchCtrl = TextEditingController();
  List<_ExerciseLite> _all = [];
  List<_ExerciseLite> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await widget.controller.fetchAllExercises();
      setState(() {
        _all = list;
        _filtered = list;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter(String q) {
    final qq = q.trim().toLowerCase();
    setState(() {
      _filtered = qq.isEmpty
          ? _all
          : _all.where((e) => e.name.toLowerCase().contains(qq)).toList();
    });
  }

  Future<void> _addExercise(_ExerciseLite ex) async {
    try {
      final id = await widget.controller.addItem(
        planId: widget.planId,
        exerciseId: ex.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${ex.name} (item #$id)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add exercises to "${widget.title}"',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: _applyFilter,
                      decoration: InputDecoration(
                        hintText: 'Search exercises',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchCtrl.text.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _applyFilter('');
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _filtered.isEmpty
                    ? const Center(child: Text('No exercises found'))
                    : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final ex = _filtered[i];
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ex.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (ex.level != null && ex.level!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Chip(
                                label: Text(ex.level!),
                                visualDensity: VisualDensity.compact,
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      subtitle: ex.description != null && ex.description!.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          ex.description!,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _addExercise(ex),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
