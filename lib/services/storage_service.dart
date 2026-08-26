import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/food_item.dart';
import '../models/exercise.dart';
import 'supabase_service.dart';

class StorageService {
  /// A lightweight in-app signal so every screen can refresh after a save.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void _notifyChanged() => changes.value++;
  static const String _keyTasks = 'college_kit_tasks_v1';
  static const String _keyHabits = 'college_kit_habits_v1';
  static const String _keyFoods = 'college_kit_foods_v1';
  static const String _keyExercises = 'college_kit_exercises_v1';
  static const String _keyCalorieGoal = 'college_kit_calorie_goal_v1';
  static const String _keyProteinGoal = 'college_kit_protein_goal_v1';
  static const String _keyWaterGoal = 'college_kit_water_goal_v1';
  static const String _keyWaterIntake = 'college_kit_water_intake_v1';
  static const String _keyStepGoal = 'college_kit_step_goal_v1';
  static const String _keyActivePlan = 'college_kit_active_plan_v1';
  static const String _keyWaterDate = 'college_kit_water_date_v1';
  static const String _keySleepDate = 'college_kit_sleep_date_v1';

  // --- SUPABASE CLOUD SYNC METHOD ---
  static Future<void> syncWithSupabaseCloud() async {
    try {
      final cloudTasks = await SupabaseService.fetchTasks();
      if (cloudTasks != null && cloudTasks.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_keyTasks, cloudTasks.map((t) => t.toJson()).toList());
      }
      final cloudHabits = await SupabaseService.fetchHabits();
      if (cloudHabits != null && cloudHabits.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_keyHabits, cloudHabits.map((h) => h.toJson()).toList());
      }
      final cloudFoods = await SupabaseService.fetchFoodLogs();
      if (cloudFoods != null && cloudFoods.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_keyFoods, cloudFoods.map((f) => f.toJson()).toList());
      }
      final cloudEx = await SupabaseService.fetchExerciseLogs();
      if (cloudEx != null && cloudEx.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_keyExercises, cloudEx.map((e) => e.toJson()).toList());
      }
      final cloudProfile = await SupabaseService.fetchUserProfile();
      if (cloudProfile != null) {
        if (cloudProfile['weight'] != null) await saveCurrentWeight((cloudProfile['weight'] as num).toDouble());
        if (cloudProfile['height'] != null) await saveHeight((cloudProfile['height'] as num).toDouble());
        if (cloudProfile['age'] != null) await saveAge(cloudProfile['age'] as int);
        if (cloudProfile['sex'] != null) await saveSex(cloudProfile['sex'] as String);
        if (cloudProfile['activity_level'] != null) await saveActivityLevel(cloudProfile['activity_level'] as String);
        if (cloudProfile['active_plan'] != null) await saveActivePlan(cloudProfile['active_plan'] as String);
        if (cloudProfile['calorie_goal'] != null) await saveCalorieGoal(cloudProfile['calorie_goal'] as int);
        if (cloudProfile['protein_goal'] != null) await saveProteinGoal(cloudProfile['protein_goal'] as int);
        if (cloudProfile['water_goal'] != null) await saveWaterGoal(cloudProfile['water_goal'] as int);
        if (cloudProfile['step_goal'] != null) await saveStepGoal(cloudProfile['step_goal'] as int);
      }
      _notifyChanged();
    } catch (e) {
      debugPrint('[StorageService] syncWithSupabaseCloud error: $e');
    }
  }

  static Future<void> _syncUserProfileToSupabase() async {
    final w = await loadCurrentWeight();
    final h = await loadHeight();
    final a = await loadAge();
    final s = await loadSex();
    final act = await loadActivityLevel();
    final plan = await loadActivePlan();
    final cal = await loadCalorieGoal();
    final prot = await loadProteinGoal();
    final water = await loadWaterGoal();
    final step = await loadStepGoal();

    SupabaseService.syncUserProfile(
      weight: w,
      height: h,
      age: a,
      sex: s,
      activityLevel: act,
      activePlan: plan,
      calorieGoal: cal,
      proteinGoal: prot,
      waterGoal: water,
      stepGoal: step,
    );
  }

  // TASKS
  static Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_keyTasks);
    if (raw == null) return _defaultTasks();
    final tasks = raw.map((item) => TaskItem.fromJson(item)).toList();

    // Rollover logic: Carry forward uncompleted tasks from past days to today
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    bool modified = false;
    final updated = tasks.map((task) {
      if (!task.isCompleted && task.dueTime != null && task.dueTime!.isBefore(startOfToday)) {
        modified = true;
        final newDue = DateTime(now.year, now.month, now.day, task.dueTime!.hour, task.dueTime!.minute);
        return task.copyWith(dueTime: newDue);
      }
      return task;
    }).toList();

    if (modified) {
      final List<String> newRaw = updated.map((t) => t.toJson()).toList();
      await prefs.setStringList(_keyTasks, newRaw);
    }
    return updated;
  }

  static Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_keyTasks, raw);
    _notifyChanged();
    SupabaseService.syncTasks(tasks);
  }

  static List<TaskItem> _defaultTasks() {
    final now = DateTime.now();
    return [
      TaskItem(
        id: 't1',
        title: 'Revise Operating Systems & Memory Management',
        category: 'Study',
        priority: 'High',
        dueTime: DateTime(now.year, now.month, now.day, 18, 0),
      ),
      TaskItem(
        id: 't2',
        title: 'Push B.Tech Capstone Project Commit to GitHub',
        category: 'Project',
        priority: 'High',
        dueTime: DateTime(now.year, now.month, now.day, 20, 0),
      ),
      TaskItem(
        id: 't3',
        title: 'Complete DBMS Lab Assignment 4',
        category: 'Assignment',
        priority: 'Medium',
        dueTime: DateTime(now.year, now.month, now.day, 22, 0),
      ),
    ];
  }

  // HABITS
  static Future<List<HabitItem>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_keyHabits);
    if (raw == null) return _defaultHabits();
    return raw.map((item) => HabitItem.fromJson(item)).toList();
  }

  static Future<void> saveHabits(List<HabitItem> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = habits.map((h) => h.toJson()).toList();
    await prefs.setStringList(_keyHabits, raw);
    _notifyChanged();
    SupabaseService.syncHabits(habits);
  }

  static List<HabitItem> _defaultHabits() {
    return [
      HabitItem(id: 'h1', title: 'Study block completed', icon: '📚', category: 'Study', streakCount: 3, longestStreak: 5),
      HabitItem(id: 'h2', title: 'Project progress', icon: '💻', category: 'Project', streakCount: 4, longestStreak: 7),
      HabitItem(id: 'h3', title: 'Coursework moved forward', icon: '🧪', category: 'Coursework', streakCount: 2, longestStreak: 4),
      HabitItem(id: 'h4', title: 'Hydration goal', icon: '💧', category: 'Hydration', streakCount: 1, longestStreak: 3),
      HabitItem(id: 'h5', title: 'Protein goal', icon: '🥚', category: 'Protein', streakCount: 1, longestStreak: 3),
    ];
  }

  // FOOD LOGS
  static Future<List<FoodLogItem>> loadFoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_keyFoods);
    if (raw == null) return [];
    return raw.map((item) => FoodLogItem.fromJson(item)).toList();
  }

  static Future<void> saveFoodLogs(List<FoodLogItem> foods) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = foods.map((f) => f.toJson()).toList();
    await prefs.setStringList(_keyFoods, raw);
    _notifyChanged();
    SupabaseService.syncFoodLogs(foods);
  }

  // EXERCISES & STEPS
  static Future<List<ExerciseLogItem>> loadExerciseLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_keyExercises);
    if (raw == null) return [];
    return raw.map((item) => ExerciseLogItem.fromJson(item)).toList();
  }

  static Future<void> saveExerciseLogs(List<ExerciseLogItem> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = exercises.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyExercises, raw);
    _notifyChanged();
    SupabaseService.syncExerciseLogs(exercises);
  }

  // GOALS & PLANS
  static Future<int> loadCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCalorieGoal) ?? 2400;
  }

  static Future<void> saveCalorieGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyCalorieGoal) == goal) return;
    await prefs.setInt(_keyCalorieGoal, goal);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  static Future<int> loadProteinGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyProteinGoal) ?? 120;
  }

  static Future<void> saveProteinGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyProteinGoal) == goal) return;
    await prefs.setInt(_keyProteinGoal, goal);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  static Future<int> loadWaterGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWaterGoal) ?? 3000;
  }

  static Future<void> saveWaterGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyWaterGoal) == goal) return;
    await prefs.setInt(_keyWaterGoal, goal);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  static Future<int> loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final savedDate = prefs.getString(_keyWaterDate);

    if (savedDate != todayStr) {
      // Day has changed! Reset water intake to 0 for the new day
      await prefs.setInt(_keyWaterIntake, 0);
      await prefs.setString(_keyWaterDate, todayStr);
      return 0;
    }
    return prefs.getInt(_keyWaterIntake) ?? 0;
  }

  static Future<void> saveWaterIntake(int intake) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await prefs.setString(_keyWaterDate, todayStr);

    if (prefs.getInt(_keyWaterIntake) == intake) return;
    await prefs.setInt(_keyWaterIntake, intake);
    _notifyChanged();
    SupabaseService.syncWaterLog(todayStr, intake);
  }

  static Future<int> loadStepGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStepGoal) ?? 10000;
  }

  static Future<void> saveStepGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyStepGoal) == goal) return;
    await prefs.setInt(_keyStepGoal, goal);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  static Future<String> loadActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActivePlan) ?? 'Balanced student routine';
  }

  static Future<void> saveActivePlan(String planName) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keyActivePlan) == planName) return;
    await prefs.setString(_keyActivePlan, planName);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  // WEIGHT LOGS
  static Future<double> loadCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('college_kit_current_weight') ?? 70.0;
  }

  static Future<void> saveCurrentWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('college_kit_current_weight') == weight) return;
    await prefs.setDouble('college_kit_current_weight', weight);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  // SLEEP LOGS
  static Future<double> loadTodaySleep() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final savedDate = prefs.getString(_keySleepDate);

    if (savedDate != todayStr) {
      // Day has changed! Reset sleep for the new day
      await prefs.setDouble('college_kit_today_sleep', 7.5);
      await prefs.setString(_keySleepDate, todayStr);
      return 7.5;
    }
    return prefs.getDouble('college_kit_today_sleep') ?? 7.5;
  }

  static Future<void> saveTodaySleep(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await prefs.setString(_keySleepDate, todayStr);

    if (prefs.getDouble('college_kit_today_sleep') == hours) return;
    await prefs.setDouble('college_kit_today_sleep', hours);
    _notifyChanged();
    SupabaseService.syncSleepLog(todayStr, hours);
  }

  // HEIGHT, AGE, SEX, ACTIVITY LEVEL
  static const String _keyHeight = 'college_kit_height_v1';
  static const String _keyAge = 'college_kit_age_v1';
  static const String _keySex = 'college_kit_sex_v1';
  static const String _keyActivityLevel = 'college_kit_activity_level_v1';

  static Future<double> loadHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyHeight) ?? 170.0;
  }

  static Future<void> saveHeight(double height) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble(_keyHeight) == height) return;
    await prefs.setDouble(_keyHeight, height);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  static Future<int> loadAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAge) ?? 21;
  }

  static Future<void> saveAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyAge) == age) return;
    await prefs.setInt(_keyAge, age);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  static Future<String> loadSex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySex) ?? 'Male';
  }

  static Future<void> saveSex(String sex) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keySex) == sex) return;
    await prefs.setString(_keySex, sex);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }

  static Future<String> loadActivityLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActivityLevel) ?? 'Moderate';
  }

  static Future<void> saveActivityLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keyActivityLevel) == level) return;
    await prefs.setString(_keyActivityLevel, level);
    _notifyChanged();
    _syncUserProfileToSupabase();
  }
}
