enum MealType {
  breakfast('아침', '🌅'),
  lunch('점심', '☀️'),
  dinner('저녁', '🌙'),
  snack('간식', '🍪');

  final String label;
  final String emoji;
  const MealType(this.label, this.emoji);
}

class MealRecord {
  final String id;
  final DateTime date;
  final MealType mealType;
  final String name;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final String? imageUrl;
  final String? memo;

  MealRecord({
    required this.id,
    required this.date,
    required this.mealType,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.imageUrl,
    this.memo,
  });

  MealRecord copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? name,
    int? calories,
    double? carbs,
    double? protein,
    double? fat,
    String? imageUrl,
    String? memo,
  }) {
    return MealRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mealType': mealType.name,
        'name': name,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
        'imageUrl': imageUrl,
        'memo': memo,
      };

  factory MealRecord.fromJson(Map<String, dynamic> json) => MealRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mealType: MealType.values.byName(json['mealType'] as String),
        name: json['name'] as String,
        calories: json['calories'] as int,
        carbs: (json['carbs'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        memo: json['memo'] as String?,
      );
}
