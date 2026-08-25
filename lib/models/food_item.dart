import 'dart:convert';

class FoodLogItem {
  final String id;
  final String name;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final String? imagePath;
  final DateTime timestamp;
  final int portionGrams;

  FoodLogItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.fiberGrams = 0,
    this.imagePath,
    required this.timestamp,
    this.portionGrams = 100,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'fiberGrams': fiberGrams,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'portionGrams': portionGrams,
    };
  }

  factory FoodLogItem.fromMap(Map<String, dynamic> map) {
    return FoodLogItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      calories: (map['calories'] ?? 0).toInt(),
      proteinGrams: (map['proteinGrams'] ?? 0).toDouble(),
      carbsGrams: (map['carbsGrams'] ?? 0).toDouble(),
      fatGrams: (map['fatGrams'] ?? 0).toDouble(),
      fiberGrams: (map['fiberGrams'] ?? 0).toDouble(),
      imagePath: map['imagePath'],
      timestamp: DateTime.parse(map['timestamp']),
      portionGrams: (map['portionGrams'] ?? 100).toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FoodLogItem.fromJson(String source) => FoodLogItem.fromMap(json.decode(source));
}
