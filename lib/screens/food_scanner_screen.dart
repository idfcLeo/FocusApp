import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../services/food_classifier_service.dart';
import '../services/food_database.dart';
import '../services/storage_service.dart';
import 'plans_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  final VoidCallback onFoodLogged;

  const FoodScannerScreen({super.key, required this.onFoodLogged});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  List<FoodLogItem> _foodLogs = [];
  int _calorieGoal = 2400;
  int _proteinGoal = 120;
  int _waterIntake = 0;
  int _waterGoal = 3000;
  String _activePlan = 'Weight Loss Plan';
  bool _isLoading = true;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    StorageService.changes.addListener(_refreshFromStorage);
    _loadFoodLogs();
  }

  void _refreshFromStorage() { if (mounted) _loadFoodLogs(); }

  @override
  void dispose() {
    StorageService.changes.removeListener(_refreshFromStorage);
    super.dispose();
  }

  Future<void> _loadFoodLogs() async {
    final results = await Future.wait([
      StorageService.loadFoodLogs(),
      StorageService.loadCalorieGoal(),
      StorageService.loadProteinGoal(),
      StorageService.loadWaterIntake(),
      StorageService.loadWaterGoal(),
      StorageService.loadActivePlan(),
    ]);
    if (!mounted) return;
    setState(() {
      _foodLogs = results[0] as List<FoodLogItem>;
      _calorieGoal = results[1] as int;
      _proteinGoal = results[2] as int;
      _waterIntake = results[3] as int;
      _waterGoal = results[4] as int;
      _activePlan = results[5] as String;
      _isLoading = false;
    });
  }

  Future<void> _saveFoodLogs() async {
    await StorageService.saveFoodLogs(_foodLogs);
    widget.onFoodLogged();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo == null) return;

      setState(() => _isAnalyzing = true);

      final imageFile = File(photo.path);
      final result = await FoodClassifierService.classifyImage(imageFile);

      setState(() => _isAnalyzing = false);

      if (!mounted) return;
      _showFoodResultDialog(result, imageFile.path);
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image capture error: $e')),
      );
    }
  }

  void _showFoodResultDialog(ClassificationResult result, String imagePath) {
    int portionGrams = 100;
    double multiplier = portionGrams / 100.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final calories = (result.nutrition.caloriesPerServing * multiplier).round();
            final protein = double.parse((result.nutrition.proteinGrams * multiplier).toStringAsFixed(1));
            final carbs = double.parse((result.nutrition.carbsGrams * multiplier).toStringAsFixed(1));
            final fat = double.parse((result.nutrition.fatGrams * multiplier).toStringAsFixed(1));

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(imagePath), width: 70, height: 70, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.label,
                              style: const TextStyle(color: Color(0xFF172033), fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(color: Color(0xFF5AC8FA), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _macroBox('Calories', '$calories kcal', const Color(0xFFFFD166)),
                      _macroBox('Protein', '${protein}g', const Color(0xFFFF8A65)),
                      _macroBox('Carbs', '${carbs}g', const Color(0xFF5AC8FA)),
                      _macroBox('Fat', '${fat}g', const Color(0xFFFFB86B)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text('Portion Size: ', style: TextStyle(color: Color(0xFF172033))),
                      Text('${portionGrams}g', style: const TextStyle(color: Color(0xFF5AC8FA), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: portionGrams.toDouble(),
                    min: 50,
                    max: 500,
                    divisions: 9,
                    activeColor: const Color(0xFF5AC8FA),
                    onChanged: (val) {
                      setModalState(() {
                        portionGrams = val.toInt();
                        multiplier = portionGrams / 100.0;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5AC8FA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final newLog = FoodLogItem(
                          id: 'f_${DateTime.now().millisecondsSinceEpoch}',
                          name: result.label,
                          calories: calories,
                          proteinGrams: protein,
                          carbsGrams: carbs,
                          fatGrams: fat,
                          imagePath: imagePath,
                          timestamp: DateTime.now(),
                          portionGrams: portionGrams,
                        );

                        setState(() => _foodLogs.insert(0, newLog));
                        _saveFoodLogs();
                        Navigator.pop(context);
                      },
                      child: const Text('Log Meal to Intake', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _macroBox(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(color: Color(0xFF172033), fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showDatabasePortionSheet(FoodNutritionData item) {
    final grams = TextEditingController(text: '100');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        final portion = (double.tryParse(grams.text) ?? 100).clamp(1, 1000);
        final factor = portion / 100;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF172033))),
            Text('Base data: ${item.servingUnit}. Change grams to scale the log.', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const SizedBox(height: 16),
            TextField(controller: grams, keyboardType: TextInputType.number, onChanged: (_) => setSheetState(() {}), decoration: const InputDecoration(labelText: 'Portion eaten (g / ml)', suffixText: 'g', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            Text('${(item.caloriesPerServing * factor).round()} kcal  •  ${(item.proteinGrams * factor).toStringAsFixed(1)}g protein', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4F46E5))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () { final log = FoodLogItem(id: 'f_${DateTime.now().microsecondsSinceEpoch}', name: item.name, calories: (item.caloriesPerServing * factor).round(), proteinGrams: item.proteinGrams * factor, carbsGrams: item.carbsGrams * factor, fatGrams: item.fatGrams * factor, timestamp: DateTime.now(), portionGrams: portion.round()); setState(() => _foodLogs.insert(0, log)); _saveFoodLogs(); Navigator.pop(ctx); }, child: const Text('Log this portion'))),
          ]),
        );
      }),
    );
  }

  void _showManualFoodEntry() {
    final name = TextEditingController(); final portion = TextEditingController(text: '100'); final calories = TextEditingController(); final protein = TextEditingController(); final carbs = TextEditingController(text: '0'); final fat = TextEditingController(text: '0'); final fiber = TextEditingController(text: '0');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create a custom dish', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF172033))),
          const SizedBox(height: 4), const Text('Enter nutrition for the exact portion you ate.', style: TextStyle(color: Color(0xFF64748B))), const SizedBox(height: 14),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Dish name', border: OutlineInputBorder())), const SizedBox(height: 10),
          TextField(controller: portion, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Portion', suffixText: 'g / ml', border: OutlineInputBorder())), const SizedBox(height: 10),
          Row(children: [Expanded(child: TextField(controller: calories, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories', border: OutlineInputBorder()))), const SizedBox(width: 10), Expanded(child: TextField(controller: protein, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein (g)', border: OutlineInputBorder())))]), const SizedBox(height: 10),
          Row(children: [Expanded(child: TextField(controller: carbs, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs (g)', border: OutlineInputBorder()))), const SizedBox(width: 10), Expanded(child: TextField(controller: fat, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fat (g)', border: OutlineInputBorder())))]), const SizedBox(height: 10),
          TextField(controller: fiber, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fiber (g)', border: OutlineInputBorder())), const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (name.text.trim().isEmpty || double.tryParse(calories.text) == null) return; final log = FoodLogItem(id: 'f_${DateTime.now().microsecondsSinceEpoch}', name: name.text.trim(), calories: (double.tryParse(calories.text) ?? 0).round(), proteinGrams: double.tryParse(protein.text) ?? 0, carbsGrams: double.tryParse(carbs.text) ?? 0, fatGrams: double.tryParse(fat.text) ?? 0, fiberGrams: double.tryParse(fiber.text) ?? 0, timestamp: DateTime.now(), portionGrams: (double.tryParse(portion.text) ?? 100).round()); setState(() => _foodLogs.insert(0, log)); _saveFoodLogs(); Navigator.pop(ctx); }, child: const Text('Log custom dish'))),
        ])),
      ),
    );
  }

  void _showManualSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = FoodDatabase.items.where((f) => f.name.toLowerCase().contains(filter.toLowerCase())).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(children: [const Expanded(child: Text('Select Meal from Database', style: TextStyle(color: Color(0xFF172033), fontSize: 18, fontWeight: FontWeight.bold))), TextButton.icon(onPressed: () { Navigator.pop(ctx); _showManualFoodEntry(); }, icon: const Icon(Icons.edit_note, size: 18), label: const Text('Custom'))]),
                  const SizedBox(height: 12),
                  TextField(
                    style: const TextStyle(color: Color(0xFF172033)),
                    decoration: InputDecoration(
                      hintText: 'Search food (e.g. Paneer, Egg, Dosa)...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setModalState(() => filter = val),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.name, style: const TextStyle(color: Color(0xFF172033), fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.category} • ${item.caloriesPerServing} kcal | ${item.proteinGrams}g P', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF5AC8FA)),
                          onTap: () { Navigator.pop(ctx); _showDatabasePortionSheet(item); },
                        );
                      },
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

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayLogs = _foodLogs.where((f) => DateFormat('yyyy-MM-dd').format(f.timestamp) == todayStr).toList();

    final totalCalories = todayLogs.fold(0, (sum, f) => sum + f.calories);
    final totalProtein = todayLogs.fold(0.0, (sum, f) => sum + f.proteinGrams);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('AI Camera Food & Calorie Scanner', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5AC8FA)))
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Camera Trigger Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F5FE), Color(0xFFFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF5AC8FA).withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 50, color: Color(0xFF5AC8FA)),
                          const SizedBox(height: 10),
                          const Text(
                            'Scan Food with Camera',
                            style: TextStyle(color: Color(0xFF172033), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Take a picture of your plate to auto-detect calories & macros',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5AC8FA),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera),
                                  label: const Text('Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF8FAFC),
                                    foregroundColor: const Color(0xFF172033),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library, color: Color(0xFF5AC8FA)),
                                  label: const Text('Gallery'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _showManualSearchModal,
                            child: const Text('+ Search Food Database Manually', style: TextStyle(color: Color(0xFF5AC8FA), fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Connected Active Goal Plan & Daily Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
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
                                    const Text('Connected Goal Plan', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(_activePlan, style: const TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: const BorderSide(color: Color(0xFF5AC8FA)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PlansScreen(onPlanActivated: () => _loadFoodLogs())),
                                ),
                                icon: const Icon(Icons.stars_outlined, size: 16, color: Color(0xFF5AC8FA)),
                                label: const Text('Plans', style: TextStyle(color: Color(0xFF5AC8FA), fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Calories Consumed', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text('$totalCalories / $_calorieGoal kcal', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(width: 1, height: 35, color: Colors.grey[300]),
                              Column(
                                children: [
                                  const Text('Budget Remaining', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text('${(_calorieGoal - totalCalories).clamp(0, 99999)} kcal', style: const TextStyle(color: Color(0xFF5FE0A0), fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(width: 1, height: 35, color: Colors.grey[300]),
                              Column(
                                children: [
                                  const Text('Total Protein', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text('${totalProtein.toStringAsFixed(1)} / $_proteinGoal g', style: const TextStyle(color: Color(0xFFFF8A65), fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(children: [const Icon(Icons.water_drop_outlined, color: Color(0xFF0EA5E9)), const SizedBox(width: 10), const Expanded(child: Text('Hydration', style: TextStyle(color: Color(0xFF172033), fontWeight: FontWeight.w700))), Text('$_waterIntake / $_waterGoal ml', style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w800))]),
                    ),

                    const SizedBox(height: 20),
                    const Text('Today\'s Food Logs', style: TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    if (todayLogs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('No food logged today yet. Scan a meal!', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      ...todayLogs.map((log) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ListTile(
                              leading: log.imagePath != null && File(log.imagePath!).existsSync()
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(File(log.imagePath!), width: 45, height: 45, fit: BoxFit.cover),
                                    )
                                  : Container(
                                      width: 45, height: 45,
                                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.restaurant, color: Color(0xFF5AC8FA)),
                                    ),
                              title: Text(log.name, style: const TextStyle(color: Color(0xFF172033), fontWeight: FontWeight.bold)),
                              subtitle: Text('${log.calories} kcal • ${log.proteinGrams}g P${log.fiberGrams > 0 ? ' • ${log.fiberGrams}g fibre' : ''} | ${log.portionGrams}g', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () {
                                  setState(() => _foodLogs.removeWhere((f) => f.id == log.id));
                                  _saveFoodLogs();
                                },
                              ),
                            ),
                          )),
                  ],
                ),

                if (_isAnalyzing)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF5AC8FA)),
                          SizedBox(height: 16),
                          Text('AI Model Analyzing Image...', style: TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
