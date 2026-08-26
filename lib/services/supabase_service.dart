import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../models/food_item.dart';
import '../models/habit.dart';
import '../models/task.dart';

class SupabaseService {
  // Configurable Supabase credentials
  // Replace with your project URL & Anon Key from Supabase Dashboard -> Settings -> API
  static String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';
  static String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static bool _isInitialized = false;

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static Future<void> init({String? url, String? anonKey}) async {
    if (url != null && url.isNotEmpty) supabaseUrl = url;
    if (anonKey != null && anonKey.isNotEmpty) supabaseAnonKey = anonKey;

    if (supabaseUrl.contains('YOUR_SUPABASE_PROJECT_ID')) {
      debugPrint('[SupabaseService] Supabase credentials not set. Using offline-first storage.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Supabase initialized successfully!');
    } catch (e) {
      debugPrint('[SupabaseService] Supabase init fallback: $e');
    }
  }

  // --- USER PROFILE & GOAL PLANS ---
  static Future<void> syncUserProfile({
    required double weight,
    required double height,
    required int age,
    required String sex,
    required String activityLevel,
    required String activePlan,
    required int calorieGoal,
    required int proteinGoal,
    required int waterGoal,
    required int stepGoal,
  }) async {
    final c = client;
    if (c == null) return;
    try {
      await c.from('user_profiles').upsert({
        'user_id': 'default_user',
        'weight': weight,
        'height': height,
        'age': age,
        'sex': sex,
        'activity_level': activityLevel,
        'active_plan': activePlan,
        'calorie_goal': calorieGoal,
        'protein_goal': proteinGoal,
        'water_goal': waterGoal,
        'step_goal': stepGoal,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseService] syncUserProfile error: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final c = client;
    if (c == null) return null;
    try {
      final data = await c.from('user_profiles').select().eq('user_id', 'default_user').maybeSingle();
      return data;
    } catch (e) {
      debugPrint('[SupabaseService] fetchUserProfile error: $e');
      return null;
    }
  }

  // --- TASKS ---
  static Future<void> syncTasks(List<TaskItem> tasks) async {
    final c = client;
    if (c == null) return;
    try {
      final rows = tasks.map((t) => {
        'id': t.id,
        'user_id': 'default_user',
        'title': t.title,
        'category': t.category,
        'priority': t.priority,
        'due_time': t.dueTime?.toIso8601String(),
        'is_completed': t.isCompleted,
        'completed_at': t.completedAt?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();
      await c.from('tasks').upsert(rows);
    } catch (e) {
      debugPrint('[SupabaseService] syncTasks error: $e');
    }
  }

  static Future<List<TaskItem>?> fetchTasks() async {
    final c = client;
    if (c == null) return null;
    try {
      final List<dynamic> response = await c.from('tasks').select().eq('user_id', 'default_user');
      return response.map((row) => TaskItem(
        id: row['id'] as String,
        title: row['title'] as String,
        category: row['category'] as String? ?? 'Study',
        priority: row['priority'] as String? ?? 'Medium',
        dueTime: row['due_time'] != null ? DateTime.tryParse(row['due_time'] as String) : null,
        isCompleted: row['is_completed'] as bool? ?? false,
        completedAt: row['completed_at'] != null ? DateTime.tryParse(row['completed_at'] as String) : null,
      )).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchTasks error: $e');
      return null;
    }
  }

  // --- HABITS ---
  static Future<void> syncHabits(List<HabitItem> habits) async {
    final c = client;
    if (c == null) return;
    try {
      final rows = habits.map((h) => {
        'id': h.id,
        'user_id': 'default_user',
        'title': h.title,
        'icon': h.icon,
        'category': h.category,
        'streak_count': h.streakCount,
        'longest_streak': h.longestStreak,
        'completed_dates': h.completedDates,
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();
      await c.from('habits').upsert(rows);
    } catch (e) {
      debugPrint('[SupabaseService] syncHabits error: $e');
    }
  }

  static Future<List<HabitItem>?> fetchHabits() async {
    final c = client;
    if (c == null) return null;
    try {
      final List<dynamic> response = await c.from('habits').select().eq('user_id', 'default_user');
      return response.map((row) => HabitItem(
        id: row['id'] as String,
        title: row['title'] as String,
        icon: row['icon'] as String? ?? '📚',
        category: row['category'] as String? ?? 'Study',
        streakCount: row['streak_count'] as int? ?? 0,
        longestStreak: row['longest_streak'] as int? ?? 0,
        completedDates: List<String>.from(row['completed_dates'] ?? []),
      )).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchHabits error: $e');
      return null;
    }
  }

  // --- FOOD LOGS ---
  static Future<void> syncFoodLogs(List<FoodLogItem> foods) async {
    final c = client;
    if (c == null) return;
    try {
      final rows = foods.map((f) => {
        'id': f.id,
        'user_id': 'default_user',
        'name': f.name,
        'calories': f.calories,
        'protein_grams': f.proteinGrams,
        'carbs_grams': f.carbsGrams,
        'fat_grams': f.fatGrams,
        'portion_grams': f.portionGrams,
        'timestamp': f.timestamp.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();
      await c.from('food_logs').upsert(rows);
    } catch (e) {
      debugPrint('[SupabaseService] syncFoodLogs error: $e');
    }
  }

  static Future<List<FoodLogItem>?> fetchFoodLogs() async {
    final c = client;
    if (c == null) return null;
    try {
      final List<dynamic> response = await c.from('food_logs').select().eq('user_id', 'default_user');
      return response.map((row) => FoodLogItem(
        id: row['id'] as String,
        name: row['name'] as String,
        calories: row['calories'] as int? ?? 0,
        proteinGrams: (row['protein_grams'] as num? ?? 0).toDouble(),
        carbsGrams: (row['carbs_grams'] as num? ?? 0).toDouble(),
        fatGrams: (row['fat_grams'] as num? ?? 0).toDouble(),
        timestamp: DateTime.parse(row['timestamp'] as String),
        portionGrams: row['portion_grams'] as int? ?? 100,
      )).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchFoodLogs error: $e');
      return null;
    }
  }

  // --- EXERCISE LOGS ---
  static Future<void> syncExerciseLogs(List<ExerciseLogItem> exercises) async {
    final c = client;
    if (c == null) return;
    try {
      final rows = exercises.map((e) => {
        'id': e.id,
        'user_id': 'default_user',
        'title': e.title,
        'duration_minutes': e.durationMinutes,
        'calories_burned': e.caloriesBurned,
        'steps': e.steps,
        'timestamp': e.timestamp.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();
      await c.from('exercise_logs').upsert(rows);
    } catch (e) {
      debugPrint('[SupabaseService] syncExerciseLogs error: $e');
    }
  }

  static Future<List<ExerciseLogItem>?> fetchExerciseLogs() async {
    final c = client;
    if (c == null) return null;
    try {
      final List<dynamic> response = await c.from('exercise_logs').select().eq('user_id', 'default_user');
      return response.map((row) => ExerciseLogItem(
        id: row['id'] as String,
        title: row['title'] as String,
        durationMinutes: row['duration_minutes'] as int? ?? 30,
        caloriesBurned: row['calories_burned'] as int? ?? 150,
        steps: row['steps'] as int? ?? 0,
        timestamp: DateTime.parse(row['timestamp'] as String),
      )).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchExerciseLogs error: $e');
      return null;
    }
  }

  // --- WATER INTAKE LOG ---
  static Future<void> syncWaterLog(String dateStr, int intakeMl) async {
    final c = client;
    if (c == null) return;
    try {
      await c.from('water_logs').upsert({
        'user_id': 'default_user',
        'log_date': dateStr,
        'intake_ml': intakeMl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, log_date');
    } catch (e) {
      debugPrint('[SupabaseService] syncWaterLog error: $e');
    }
  }

  // --- SLEEP LOG ---
  static Future<void> syncSleepLog(String dateStr, double sleepHours) async {
    final c = client;
    if (c == null) return;
    try {
      await c.from('sleep_logs').upsert({
        'user_id': 'default_user',
        'log_date': dateStr,
        'sleep_hours': sleepHours,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, log_date');
    } catch (e) {
      debugPrint('[SupabaseService] syncSleepLog error: $e');
    }
  }
}
