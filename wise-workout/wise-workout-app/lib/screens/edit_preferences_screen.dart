import 'package:flutter/material.dart';
import '../services/questionnaire_service.dart';

const genderOptions = ['male', 'female'];
const workoutDaysOptions = [
  '1-2 times a week',
  '3-4 times a week',
  '5-6 times a week'
];
const workoutTimeOptions = [
  'Quick (e.g. 5 Minutes during Lunch Break)',
  'Short (10-20 Minutes)',
  'Medium (25-45 Minutes)',
  'Long (1 Hour or more)'
];

const equipmentOptions = ['Body Weight', 'With Equipment', 'Both'];
const fitnessGoalOptions = [
  'Lose Weight',
  'Build Muscle',
  'Improve Endurance',
  'Tone Up',
  'Improve Flexibility'
];
const fitnessLevelOptions = ['Beginner', 'Intermediate', 'Advanced'];
const enjoyedWorkoutOptions = [
  'Yoga Training',
  'Strength Training',
  'Cardio Training'
];

class EditPreferencesScreen extends StatefulWidget {
  final Map<String, dynamic> preferences;

  const EditPreferencesScreen({Key? key, required this.preferences}) : super(key: key);

  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  late String gender;
  late String workoutDays;
  late String workoutTime;
  late String equipment;
  late String fitnessGoal;
  late String fitnessLevel;
  late String enjoyedWorkout;
  late String injury;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController bmiController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.preferences;
    gender = genderOptions.contains(p['gender']) ? p['gender'] : genderOptions.first;
    workoutDays = workoutDaysOptions.contains(p['workout_days']) ? p['workout_days'] : workoutDaysOptions.first;
    workoutTime = workoutTimeOptions.contains(p['workout_time']) ? p['workout_time'] : workoutTimeOptions.first;
    equipment = equipmentOptions.contains(p['equipment_pref']) ? p['equipment_pref'] : equipmentOptions.first;
    fitnessGoal = fitnessGoalOptions.contains(p['fitness_goal']) ? p['fitness_goal'] : fitnessGoalOptions.first;
    fitnessLevel = fitnessLevelOptions.contains(p['fitness_level']) ? p['fitness_level'] : fitnessLevelOptions.first;
    enjoyedWorkout = enjoyedWorkoutOptions.contains(p['enjoyed_workouts']) ? p['enjoyed_workouts'] : enjoyedWorkoutOptions.first;
    injury = p['injury'] ?? '';
    heightController = TextEditingController(text: (p['height_cm']?.toString() ?? '170'));
    weightController = TextEditingController(text: (p['weight_kg']?.toString() ?? '70'));
    bmiController = TextEditingController(text: (p['bmi_value']?.toString() ?? '21.5'));
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    bmiController.dispose();
    super.dispose();
  }

  void _savePreferences() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedPrefs = {
        'gender': gender,
        'workout_days': workoutDays,
        'workout_time': workoutTime,
        'equipment_pref': equipment,
        'fitness_goal': fitnessGoal,
        'fitness_level': fitnessLevel,
        'enjoyed_workouts': enjoyedWorkout,
        'injury': injury,
        'height_cm': double.tryParse(heightController.text) ?? 170.0,
        'weight_kg': double.tryParse(weightController.text) ?? 70.0,
        'bmi_value': double.tryParse(bmiController.text) ?? 21.5,
      };

      final success = await QuestionnaireService.updatePreferences(updatedPrefs);

      if (success) {
        Navigator.pop(context, updatedPrefs);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update preferences. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Fitness Preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.person, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: gender,
                isExpanded: true,
                items: genderOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => gender = v!),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Workout Days',
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.blueGrey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: workoutDays,
                isExpanded: true,
                items: workoutDaysOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => workoutDays = v!),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Workout Time',
                  prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: workoutTime,
                isExpanded: true,
                items: workoutTimeOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => workoutTime = v!),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Equipment',
                  prefixIcon: const Icon(Icons.fitness_center, color: Colors.deepOrange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: equipment,
                isExpanded: true,
                items: equipmentOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => equipment = v!),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Goal',
                  prefixIcon: const Icon(Icons.flag, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: fitnessGoal,
                isExpanded: true,
                items: fitnessGoalOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => fitnessGoal = v!),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Level',
                  prefixIcon: const Icon(Icons.grade, color: Colors.purple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: fitnessLevel,
                isExpanded: true,
                items: fitnessLevelOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => fitnessLevel = v!),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Enjoyed Workouts',
                  prefixIcon: const Icon(Icons.sentiment_satisfied, color: Colors.amber),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                value: enjoyedWorkout,
                isExpanded: true,
                items: enjoyedWorkoutOptions.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => enjoyedWorkout = v!),
              ),
              const SizedBox(height: 18),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Injury (type if any, or leave blank)',
                  prefixIcon: const Icon(Icons.healing, color: Colors.red),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                initialValue: injury,
                onChanged: (v) => setState(() => injury = v),
              ),
              const SizedBox(height: 28),

              // Bottom row for height, weight, BMI
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        prefixIcon: const Icon(Icons.height, color: Colors.teal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? '!' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: const Icon(Icons.monitor_weight, color: Colors.deepOrange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? '!' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: bmiController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'BMI',
                        prefixIcon: const Icon(Icons.percent, color: Colors.blueGrey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? '!' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Preferences'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _savePreferences,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
