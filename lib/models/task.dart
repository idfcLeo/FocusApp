import 'dart:convert';

class TaskItem {
  final String id;
  final String title;
  final String category; // Study, Assignment, Exam, Project, Personal
  final String priority; // High, Medium, Low
  final DateTime? dueTime;
  final bool isCompleted;
  final bool isRecurring;
  final DateTime? completedAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    this.dueTime,
    this.isCompleted = false,
    this.isRecurring = false,
    this.completedAt,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? category,
    String? priority,
    DateTime? dueTime,
    bool? isCompleted,
    bool? isRecurring,
    DateTime? completedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'dueTime': dueTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'isRecurring': isRecurring,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Study',
      priority: map['priority'] ?? 'Medium',
      dueTime: map['dueTime'] != null ? DateTime.parse(map['dueTime']) : null,
      isCompleted: map['isCompleted'] ?? false,
      isRecurring: map['isRecurring'] ?? false,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskItem.fromJson(String source) => TaskItem.fromMap(json.decode(source));
}
