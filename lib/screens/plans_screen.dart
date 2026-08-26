import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class PlansScreen extends StatefulWidget {
  final VoidCallback onPlanActivated;

  const PlansScreen({super.key, required this.onPlanActivated});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  double _weight = 70;
  double _height = 170;
  int _age = 21;
  String _sex = 'Male';
  String _activityLevel = 'Moderate';

  double get _activityMultiplier => {'Low': 1.2, 'Light': 1.375, 'Moderate': 1.55, 'High': 1.725}[_activityLevel] ?? 1.55;

  String _activePlan = 'Weight Loss Plan';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    StorageService.changes.addListener(_refreshFromStorage);
    _loadState();
  }

  void _refreshFromStorage() { if (mounted) _loadState(); }

  @override
  void dispose() {
    StorageService.changes.removeListener(_refreshFromStorage);
    super.dispose();
  }

  Future<void> _loadState() async {
    final w = await StorageService.loadCurrentWeight();
    final h = await StorageService.loadHeight();
    final a = await StorageService.loadAge();
    final s = await StorageService.loadSex();
    final act = await StorageService.loadActivityLevel();
    final plan = await StorageService.loadActivePlan();
    if (!mounted) return;
    setState(() {
      _weight = w;
      _height = h;
      _age = a;
      _sex = s;
      _activityLevel = act;
      _activePlan = plan;
      _isLoading = false;
    });
  }

  Future<void> _syncActivePlanGoals() async {
    int cal = _tdee;
    int prot = (_weight * 1.5).round();
    int water = 3000;
    int steps = 8000;

    if (_activePlan == 'Weight Loss Plan') {
      cal = _tdee - 400;
      prot = (_weight * 1.8).round();
      water = 3000;
      steps = 10000;
    } else if (_activePlan == 'Muscle Gain Plan') {
      cal = _tdee + 350;
      prot = (_weight * 2.1).round();
      water = 3500;
      steps = 8000;
    }

    await StorageService.saveCalorieGoal(cal);
    await StorageService.saveProteinGoal(prot);
    await StorageService.saveWaterGoal(water);
    await StorageService.saveStepGoal(steps);
  }

  double get _bmi {
    final hMeter = _height / 100.0;
    return _weight / (hMeter * hMeter);
  }

  String get _bmiCategory {
    final b = _bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal Weight';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    final b = _bmi;
    if (b < 18.5) return const Color(0xFF5AC8FA);
    if (b < 25.0) return const Color(0xFF5FE0A0);
    if (b < 30.0) return const Color(0xFFFFB86B);
    return const Color(0xFFFF6B6B);
  }

  String get _idealWeightRange {
    final hMeter = _height / 100.0;
    final minW = (18.5 * hMeter * hMeter).round();
    final maxW = (24.9 * hMeter * hMeter).round();
    return '$minW - $maxW Kg';
  }

  int get _bmr {
    if (_sex == 'Male') {
      return (10 * _weight + 6.25 * _height - 5 * _age + 5).round();
    } else {
      return (10 * _weight + 6.25 * _height - 5 * _age - 161).round();
    }
  }

  int get _tdee => (_bmr * _activityMultiplier).round();

  Future<void> _activatePlan({
    required String name,
    required int calories,
    required int protein,
    required int water,
    required int steps,
  }) async {
    await StorageService.saveActivePlan(name);
    await StorageService.saveCalorieGoal(calories);
    await StorageService.saveProteinGoal(protein);
    await StorageService.saveWaterGoal(water);
    await StorageService.saveStepGoal(steps);

    setState(() {
      _activePlan = name;
    });

    widget.onPlanActivated();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activated "$name"! Goals updated across app.'),
        backgroundColor: const Color(0xFF5FE0A0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmiVal = _bmi.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('BMI & Fitness Goal Plans', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5FE0A0)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Active Plan Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE9FBF2), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF5FE0A0).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFF5FE0A0), size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Active Goal Plan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(_activePlan, style: const TextStyle(color: Color(0xFF172033), fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // BMI & Body Metrics Card
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BMI & Metabolic Rate', style: TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                          Icon(Icons.monitor_weight_outlined, color: Color(0xFF5AC8FA)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(bmiVal, style: TextStyle(color: _bmiColor, fontSize: 28, fontWeight: FontWeight.bold)),
                              Text(_bmiCategory, style: TextStyle(color: _bmiColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(width: 1, height: 40, color: Colors.grey[800]),
                          Column(
                            children: [
                              Text(_idealWeightRange, style: const TextStyle(color: Color(0xFF5FE0A0), fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('Ideal Weight Goal', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          Container(width: 1, height: 40, color: Colors.grey[800]),
                          Column(
                            children: [
                              Text('$_tdee kcal', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('TDEE Maintenance', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 8),

                      // Quick Body Parameter Adjustment Inputs
                      Row(
                        children: [
                          Expanded(
                            child: _numInput('Weight (kg)', _weight.toStringAsFixed(1), (val) async {
                              final d = double.tryParse(val);
                              if (d != null) {
                                setState(() => _weight = d);
                                await StorageService.saveCurrentWeight(d);
                                _syncActivePlanGoals();
                              }
                            }),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _numInput('Height (cm)', _height.toStringAsFixed(0), (val) async {
                              final d = double.tryParse(val);
                              if (d != null) {
                                setState(() => _height = d);
                                await StorageService.saveHeight(d);
                                _syncActivePlanGoals();
                              }
                            }),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _numInput('Age', _age.toString(), (val) async {
                              final i = int.tryParse(val);
                              if (i != null) {
                                setState(() => _age = i);
                                await StorageService.saveAge(i);
                                _syncActivePlanGoals();
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _selectInput('Sex', _sex, ['Male', 'Female'], (v) async {
                              if (v != null) {
                                setState(() => _sex = v);
                                await StorageService.saveSex(v);
                                _syncActivePlanGoals();
                              }
                            }),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _selectInput('Activity Level', _activityLevel, ['Low', 'Light', 'Moderate', 'High'], (v) async {
                              if (v != null) {
                                setState(() => _activityLevel = v);
                                await StorageService.saveActivityLevel(v);
                                _syncActivePlanGoals();
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                const Text('Available Goal Plans', style: TextStyle(color: Color(0xFF172033), fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 1. Weight Loss Plan Card
                _planCard(
                  title: 'Weight Loss Plan',
                  icon: '📉',
                  color: const Color(0xFF5FE0A0),
                  desc: 'Calorie deficit for steady fat loss & lean physique',
                  calories: _tdee - 400,
                  protein: (_weight * 1.8).round(),
                  water: 3000,
                  steps: 10000,
                ),

                const SizedBox(height: 12),

                // 2. Muscle Gain Plan Card
                _planCard(
                  title: 'Muscle Gain Plan',
                  icon: '🏋️',
                  color: const Color(0xFFFF8A65),
                  desc: 'High protein & calorie surplus for strength & hypertrophy',
                  calories: _tdee + 350,
                  protein: (_weight * 2.1).round(),
                  water: 3500,
                  steps: 8000,
                ),

                const SizedBox(height: 12),

                // 3. Lean Maintenance Plan Card
                _planCard(
                  title: 'Lean Maintenance Plan',
                  icon: '⚖️',
                  color: const Color(0xFF5AC8FA),
                  desc: 'Maintain weight, stay energized, & optimize college productivity',
                  calories: _tdee,
                  protein: (_weight * 1.5).round(),
                  water: 3000,
                  steps: 8000,
                ),
              ],
            ),
    );
  }

  Widget _numInput(String label, String initialVal, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialVal,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Color(0xFF172033), fontSize: 13, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _planCard({
    required String title,
    required String icon,
    required Color color,
    required String desc,
    required int calories,
    required int protein,
    required int water,
    required int steps,
  }) {
    final isCurrent = _activePlan == title;

    return InkWell(
      onTap: () => _activatePlan(
        name: title,
        calories: calories,
        protein: protein,
        water: water,
        steps: steps,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isCurrent ? color : const Color(0xFFE2E8F0), width: isCurrent ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text('ACTIVE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 14,
              runSpacing: 10,
              children: [
                _metricChip('Target Cal', '$calories kcal', const Color(0xFFFFD166)),
                _metricChip('Protein', '${protein}g', const Color(0xFFFF8A65)),
                _metricChip('Water', '${(water / 250).round()} glasses', const Color(0xFF5AC8FA)),
                _metricChip('Steps Goal', '$steps', const Color(0xFF5FE0A0)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? const Color(0xFFF8FAFC) : color,
                  foregroundColor: isCurrent ? color : Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _activatePlan(
                  name: title,
                  calories: calories,
                  protein: protein,
                  water: water,
                  steps: steps,
                ),
                child: Text(
                  isCurrent ? 'Plan Active' : 'Activate Plan',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _selectInput(String label, String value, List<String> items, ValueChanged<String?> change) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          isDense: true,
          style: const TextStyle(color: Color(0xFF172033), fontSize: 12, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          items: items.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: change,
        ),
      ],
    );
  }
}
