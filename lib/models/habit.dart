import 'dart:convert';

class HabitItem {
  final String id;
  final String title;
  final String icon;
  final String category; // Study, Fitness, Hydration, Mindfulness, General
  final List<String> completedDates; // List of YYYY-MM-DD
  final int streakCount;
  final int longestStreak;

  HabitItem({
    required this.id,
    required this.title,
    this.icon = '🔥',
    this.category = 'General',
    List<String>? completedDates,
    this.streakCount = 0,
    this.longestStreak = 0,
  }) : completedDates = completedDates ?? [];

  HabitItem copyWith({
    String? id,
    String? title,
    String? icon,
    String? category,
    List<String>? completedDates,
    int? streakCount,
    int? longestStreak,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      completedDates: completedDates ?? List.from(this.completedDates),
      streakCount: streakCount ?? this.streakCount,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'category': category,
      'completedDates': completedDates,
      'streakCount': streakCount,
      'longestStreak': longestStreak,
    };
  }

  factory HabitItem.fromMap(Map<String, dynamic> map) {
    return HabitItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      icon: map['icon'] ?? '🔥',
      category: map['category'] ?? 'General',
      completedDates: List<String>.from(map['completedDates'] ?? []),
      streakCount: map['streakCount'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory HabitItem.fromJson(String source) => HabitItem.fromMap(json.decode(source));
}
