class UserProfile {
  final String name;
  final int age;
  final double height; // cm
  final double currentWeight; // kg
  final double targetWeight; // kg
  final String gender; // male, female
  final int dailyCalorieGoal;
  final int dailyWaterGoalMl;
  final int dailyStepGoal;
  final DateTime? targetDate;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    this.gender = 'female',
    this.dailyCalorieGoal = 1500,
    this.dailyWaterGoalMl = 2000,
    this.dailyStepGoal = 10000,
    this.targetDate,
  });

  double get bmi => currentWeight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return '저체중';
    if (bmi < 23) return '정상';
    if (bmi < 25) return '과체중';
    if (bmi < 30) return '비만';
    return '고도비만';
  }

  double get weightToLose => currentWeight - targetWeight;
  double get progressPercent {
    if (weightToLose <= 0) return 1.0;
    return 0.0; // Will be calculated with initial weight
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? gender,
    int? dailyCalorieGoal,
    int? dailyWaterGoalMl,
    int? dailyStepGoal,
    DateTime? targetDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      gender: gender ?? this.gender,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'height': height,
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'gender': gender,
        'dailyCalorieGoal': dailyCalorieGoal,
        'dailyWaterGoalMl': dailyWaterGoalMl,
        'dailyStepGoal': dailyStepGoal,
        'targetDate': targetDate?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        age: json['age'] as int,
        height: (json['height'] as num).toDouble(),
        currentWeight: (json['currentWeight'] as num).toDouble(),
        targetWeight: (json['targetWeight'] as num).toDouble(),
        gender: json['gender'] as String? ?? 'female',
        dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 1500,
        dailyWaterGoalMl: json['dailyWaterGoalMl'] as int? ?? 2000,
        dailyStepGoal: json['dailyStepGoal'] as int? ?? 10000,
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'] as String)
            : null,
      );

  factory UserProfile.defaultProfile() => UserProfile(
        name: '핏메이트 사용자',
        age: 30,
        height: 165,
        currentWeight: 68,
        targetWeight: 58,
        gender: 'female',
        dailyCalorieGoal: 1500,
        dailyWaterGoalMl: 2000,
        dailyStepGoal: 10000,
        targetDate: DateTime.now().add(const Duration(days: 90)),
      );
}
