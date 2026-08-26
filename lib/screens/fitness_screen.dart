import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';
import 'food_scanner_screen.dart';
import 'plans_screen.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  List<ExerciseLogItem> _exercises = [];
  List<FoodLogItem> _foods = [];
  int _calorieGoal = 2400;
  int _proteinGoal = 120;
  int _waterGoal = 3000;
  int _waterIntake = 0;
  int _stepGoal = 10000;
  double _currentWeight = 70.0;
  double _todaySleepHours = 7.5;
  String _activePlan = 'Weight Loss Plan';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    StorageService.changes.addListener(_refreshFromStorage);
    _loadData();
  }

  void _refreshFromStorage() { if (mounted) _loadData(); }

  @override
  void dispose() {
    StorageService.changes.removeListener(_refreshFromStorage);
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadedEx = await StorageService.loadExerciseLogs();
    final loadedFoods = await StorageService.loadFoodLogs();
    final goalCal = await StorageService.loadCalorieGoal();
    final goalProt = await StorageService.loadProteinGoal();
    final goalWater = await StorageService.loadWaterGoal();
    final intakeWater = await StorageService.loadWaterIntake();
    final goalStep = await StorageService.loadStepGoal();
    final w = await StorageService.loadCurrentWeight();
    final sleep = await StorageService.loadTodaySleep();
    final plan = await StorageService.loadActivePlan();

    if (!mounted) return;
    setState(() {
      _exercises = loadedEx;
      _foods = loadedFoods;
      _calorieGoal = goalCal;
      _proteinGoal = goalProt;
      _waterGoal = goalWater;
      _waterIntake = intakeWater;
      _stepGoal = goalStep;
      _currentWeight = w;
      _todaySleepHours = sleep;
      _activePlan = plan;
      _isLoading = false;
    });
  }

  Future<void> _saveExercises() async {
    await StorageService.saveExerciseLogs(_exercises);
  }

  static const String _idealWeightRange = '62 - 76 Kg';

  void _showAddExerciseModal() {
    final titleController = TextEditingController();
    final calController = TextEditingController();
    final durController = TextEditingController();
    String selectedWorkout = 'Running';

    final presetWorkouts = {
      'Running': {'cal': 300, 'dur': 30},
      'Weightlifting': {'cal': 220, 'dur': 45},
      'Cycling': {'cal': 250, 'dur': 30},
      'Pushups & Calisthenics': {'cal': 150, 'dur': 20},
      'Swimming': {'cal': 350, 'dur': 30},
      'Brisk Walking': {'cal': 140, 'dur': 30},
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log Exercise / Workout', style: TextStyle(color: Color(0xFF172033), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedWorkout,
                    dropdownColor: const Color(0xFFF8FAFC),
                    style: const TextStyle(color: Color(0xFF172033)),
                    decoration: const InputDecoration(labelText: 'Preset Workout', labelStyle: TextStyle(color: Colors.grey)),
                    items: presetWorkouts.keys.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedWorkout = val;
                          titleController.text = val;
                          calController.text = presetWorkouts[val]!['cal'].toString();
                          durController.text = presetWorkouts[val]!['dur'].toString();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Color(0xFF172033)),
                    decoration: InputDecoration(
                      hintText: 'Workout name (e.g. Legs & Core)',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: calController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFF172033)),
                          decoration: InputDecoration(
                            labelText: 'Calories Burned (kcal)',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: durController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFF172033)),
                          decoration: InputDecoration(
                            labelText: 'Duration (mins)',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A65),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final name = titleController.text.trim().isEmpty ? selectedWorkout : titleController.text.trim();
                        final cal = int.tryParse(calController.text) ?? presetWorkouts[selectedWorkout]!['cal']!;
                        final dur = int.tryParse(durController.text) ?? presetWorkouts[selectedWorkout]!['dur']!;

                        final newEx = ExerciseLogItem(
                          id: 'e_${DateTime.now().millisecondsSinceEpoch}',
                          title: name,
                          caloriesBurned: cal,
                          durationMinutes: dur,
                          timestamp: DateTime.now(),
                        );

                        setState(() => _exercises.insert(0, newEx));
                        _saveExercises();
                        Navigator.pop(context);
                      },
                      child: const Text('Add Workout Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  void _showAddStepsModal() {
    final stepsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Log Step Count', style: TextStyle(color: Color(0xFF172033), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: stepsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF172033)),
                decoration: InputDecoration(
                  hintText: 'e.g. 6500 steps',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5FE0A0),
                    foregroundColor: const Color(0xFF06282B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final steps = int.tryParse(stepsController.text) ?? 0;
                    if (steps <= 0) return;

                    final burned = (steps * 0.04).round();

                    final newEx = ExerciseLogItem(
                      id: 's_${DateTime.now().millisecondsSinceEpoch}',
                      title: '$steps Daily Steps Walked',
                      caloriesBurned: burned,
                      steps: steps,
                      timestamp: DateTime.now(),
                    );

                    setState(() => _exercises.insert(0, newEx));
                    _saveExercises();
                    Navigator.pop(context);
                  },
                  child: const Text('Save Step Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSleepModal() {
    final sleepController = TextEditingController(text: _todaySleepHours.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Log Today\'s Sleep (Hours)', style: TextStyle(color: Color(0xFF172033))),
          content: TextField(
            controller: sleepController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Color(0xFF172033)),
            decoration: const InputDecoration(
              labelText: 'Hours of sleep (e.g. 7.5)',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              onPressed: () {
                final hrs = double.tryParse(sleepController.text) ?? 7.5;
                setState(() => _todaySleepHours = hrs);
                StorageService.saveTodaySleep(hrs);
                Navigator.pop(ctx);
              },
              child: const Text('Save Sleep'),
            ),
          ],
        );
      },
    );
  }

  void _showWeightModal() {
    final weightController = TextEditingController(text: _currentWeight.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Log Current Weight (Kg)', style: TextStyle(color: Color(0xFF172033))),
          content: TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Color(0xFF172033)),
            decoration: const InputDecoration(
              labelText: 'Weight in Kg (e.g. 68.5)',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5AC8FA)),
              onPressed: () {
                final w = double.tryParse(weightController.text) ?? 70.0;
                setState(() => _currentWeight = w);
                StorageService.saveCurrentWeight(w);
                Navigator.pop(ctx);
              },
              child: const Text('Save Weight'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayFoods = _foods.where((f) => DateFormat('yyyy-MM-dd').format(f.timestamp) == todayStr).toList();
    final todayEx = _exercises.where((e) => DateFormat('yyyy-MM-dd').format(e.timestamp) == todayStr).toList();

    final consumedCal = todayFoods.fold(0, (sum, f) => sum + f.calories);
    final consumedProt = todayFoods.fold(0.0, (sum, f) => sum + f.proteinGrams);
    final consumedCarbs = todayFoods.fold(0.0, (sum, f) => sum + f.carbsGrams);
    final consumedFat = todayFoods.fold(0.0, (sum, f) => sum + f.fatGrams);

    final burnedCal = todayEx.fold(0, (sum, e) => sum + e.caloriesBurned);
    final totalSteps = todayEx.fold(0, (sum, e) => sum + e.steps);

    final netCalories = consumedCal - burnedCal;
    final remainingCal = _calorieGoal - netCalories;

    // Macro Percentages against targets
    final protPct = (_proteinGoal > 0 ? (consumedProt / _proteinGoal) * 100 : 0).clamp(0, 100).toInt();
    final carbPct = ((consumedCarbs / 250) * 100).clamp(0, 100).toInt();
    final fatPct = ((consumedFat / 70) * 100).clamp(0, 100).toInt();

    final waterGlasses = (_waterGoal / 250).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Fitness & Health Metrics Hub', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8A65)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Food Track & Macro Bars Card (Reference UI match)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Track Food & Nutrition', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                                InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlansScreen(onPlanActivated: _loadData))),
                                  child: Text('Goal: $_calorieGoal cal • Active: $_activePlan 🎯', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5AC8FA),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FoodScannerScreen(onFoodLogged: _loadData)),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 14),
                            label: const Text('AI Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Macro Bars 2x2 Grid (Protein %, Carb %, Fat %, Fiber %)
                      Row(
                        children: [
                          Expanded(child: _macroBar('Protein', '$protPct%', consumedProt, _proteinGoal.toDouble(), const Color(0xFFFF8A65))),
                          const SizedBox(width: 12),
                          Expanded(child: _macroBar('Carb', '$carbPct%', consumedCarbs, 250, const Color(0xFF5AC8FA))),
                          const SizedBox(width: 12),
                          Expanded(child: _macroBar('Fat', '$fatPct%', consumedFat, 70, const Color(0xFFFFB86B))),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Metrics List (Weight, Workout, Steps, Sleep, Water) Inspired by Screenshot
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      // Weight Metric
                      _metricRowItem(
                        icon: Icons.monitor_weight_outlined,
                        iconColor: const Color(0xFF5AC8FA),
                        title: 'Weight',
                        subtitle: 'Current: $_currentWeight Kg • Ideal: $_idealWeightRange',
                        trailingAction: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5AC8FA)),
                          onPressed: _showWeightModal,
                        ),
                      ),
                      const Divider(color: Color(0xFFE2E8F0)),

                      // Workout Metric
                      _metricRowItem(
                        icon: Icons.local_fire_department_outlined,
                        iconColor: const Color(0xFFFF8A65),
                        title: 'Workout Burned',
                        subtitle: 'Burned: $burnedCal kcal (Net Remaining: $remainingCal kcal)',
                        trailingAction: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF8A65)),
                          onPressed: _showAddExerciseModal,
                        ),
                      ),
                      const Divider(color: Color(0xFFE2E8F0)),

                      // Steps Metric
                      _metricRowItem(
                        icon: Icons.directions_walk_outlined,
                        iconColor: const Color(0xFF5FE0A0),
                        title: 'Steps',
                        subtitle: '$totalSteps of $_stepGoal steps',
                        trailingAction: IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF5FE0A0)),
                          onPressed: _showAddStepsModal,
                        ),
                      ),
                      const Divider(color: Color(0xFFE2E8F0)),

                      // Sleep Metric
                      _metricRowItem(
                        icon: Icons.nightlight_round_outlined,
                        iconColor: const Color(0xFF4F46E5),
                        title: 'Sleep Tracker',
                        subtitle: 'Today: $_todaySleepHours / 8.0 hours',
                        trailingAction: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4F46E5)),
                          onPressed: _showSleepModal,
                        ),
                      ),
                      const Divider(color: Color(0xFFE2E8F0)),

                      // Water Metric
                      _metricRowItem(
                        icon: Icons.water_drop_outlined,
                        iconColor: const Color(0xFF5AC8FA),
                        title: 'Water Hydration',
                        subtitle: 'Today: $_waterIntake / $_waterGoal ml (${(_waterIntake / 250).round()} / $waterGlasses glasses)',
                        trailingAction: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5AC8FA)),
                          onPressed: () async {
                            final newWater = _waterIntake + 250;
                            setState(() => _waterIntake = newWater);
                            await StorageService.saveWaterIntake(newWater);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Today\'s Exercise Logs', style: TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                if (todayEx.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('No workouts logged today yet.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...todayEx.map((ex) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFF3E8),
                            child: Icon(Icons.fitness_center, color: Color(0xFFFF8A65)),
                          ),
                          title: Text(ex.title, style: const TextStyle(color: Color(0xFF172033), fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            ex.steps > 0
                                ? '${ex.steps} steps • ${ex.caloriesBurned} kcal burned'
                                : '${ex.durationMinutes} mins • ${ex.caloriesBurned} kcal burned',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () {
                              setState(() => _exercises.removeWhere((e) => e.id == ex.id));
                              _saveExercises();
                            },
                          ),
                        ),
                      )),
              ],
            ),
    );
  }

  Widget _macroBar(String title, String pctText, double current, double maxVal, Color color) {
    final progress = (current / (maxVal > 0 ? maxVal : 1)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title: ', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(pctText, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF8FAFC),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _metricRowItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailingAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF172033), fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          trailingAction,
        ],
      ),
    );
  }
}
