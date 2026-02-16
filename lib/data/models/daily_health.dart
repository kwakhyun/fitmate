class DailyHealth {
  final String id;
  final DateTime date;
  final int waterMl;
  final int steps;
  final double sleepHours;
  final int exerciseMinutes;
  final String? mood;

  DailyHealth({
    required this.id,
    required this.date,
    this.waterMl = 0,
    this.steps = 0,
    this.sleepHours = 0,
    this.exerciseMinutes = 0,
    this.mood,
  });

  DailyHealth copyWith({
    String? id,
    DateTime? date,
    int? waterMl,
    int? steps,
    double? sleepHours,
    int? exerciseMinutes,
    String? mood,
  }) {
    return DailyHealth(
      id: id ?? this.id,
      date: date ?? this.date,
      waterMl: waterMl ?? this.waterMl,
      steps: steps ?? this.steps,
      sleepHours: sleepHours ?? this.sleepHours,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      mood: mood ?? this.mood,
    );
  }

  int get waterCups => (waterMl / 250).floor();
  double get waterLiters => waterMl / 1000;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'waterMl': waterMl,
        'steps': steps,
        'sleepHours': sleepHours,
        'exerciseMinutes': exerciseMinutes,
        'mood': mood,
      };

  factory DailyHealth.fromJson(Map<String, dynamic> json) => DailyHealth(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        waterMl: json['waterMl'] as int? ?? 0,
        steps: json['steps'] as int? ?? 0,
        sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0,
        exerciseMinutes: json['exerciseMinutes'] as int? ?? 0,
        mood: json['mood'] as String?,
      );
}
