import 'dart:convert';

class ExerciseLogItem {
  final String id;
  final String title;
  final int caloriesBurned;
  final int durationMinutes;
  final int steps;
  final DateTime timestamp;

  ExerciseLogItem({
    required this.id,
    required this.title,
    required this.caloriesBurned,
    this.durationMinutes = 0,
    this.steps = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'caloriesBurned': caloriesBurned,
      'durationMinutes': durationMinutes,
      'steps': steps,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExerciseLogItem.fromMap(Map<String, dynamic> map) {
    return ExerciseLogItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      caloriesBurned: (map['caloriesBurned'] ?? 0).toInt(),
      durationMinutes: (map['durationMinutes'] ?? 0).toInt(),
      steps: (map['steps'] ?? 0).toInt(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseLogItem.fromJson(String source) => ExerciseLogItem.fromMap(json.decode(source));
}
