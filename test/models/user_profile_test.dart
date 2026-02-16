import 'package:flutter_test/flutter_test.dart';
import 'package:fitmate/data/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('defaultProfile returns valid default values', () {
      final profile = UserProfile.defaultProfile();

      expect(profile.name, '핏메이트 사용자');
      expect(profile.age, 30);
      expect(profile.height, 165);
      expect(profile.currentWeight, 68);
      expect(profile.targetWeight, 58);
      expect(profile.gender, 'female');
      expect(profile.dailyCalorieGoal, 1500);
      expect(profile.dailyWaterGoalMl, 2000);
      expect(profile.dailyStepGoal, 10000);
    });

    test('BMI calculation is correct', () {
      final profile = UserProfile(
        name: 'Test',
        age: 25,
        height: 170,
        currentWeight: 70,
        targetWeight: 60,
      );

      // BMI = 70 / (1.7 * 1.7) ≈ 24.22
      expect(profile.bmi, closeTo(24.22, 0.1));
    });

    test('BMI category returns correct label', () {
      expect(
        UserProfile(
                name: 'A',
                age: 20,
                height: 170,
                currentWeight: 50,
                targetWeight: 45)
            .bmiCategory,
        '저체중',
      );
      expect(
        UserProfile(
                name: 'B',
                age: 20,
                height: 170,
                currentWeight: 65,
                targetWeight: 60)
            .bmiCategory,
        '정상',
      );
      expect(
        UserProfile(
                name: 'C',
                age: 20,
                height: 170,
                currentWeight: 72,
                targetWeight: 60)
            .bmiCategory,
        '과체중',
      );
      expect(
        UserProfile(
                name: 'D',
                age: 20,
                height: 170,
                currentWeight: 85,
                targetWeight: 70)
            .bmiCategory,
        '비만',
      );
      expect(
        UserProfile(
                name: 'E',
                age: 20,
                height: 170,
                currentWeight: 110,
                targetWeight: 80)
            .bmiCategory,
        '고도비만',
      );
    });

    test('weightToLose calculates correctly', () {
      final profile = UserProfile(
        name: 'Test',
        age: 25,
        height: 170,
        currentWeight: 75,
        targetWeight: 65,
      );

      expect(profile.weightToLose, 10);
    });

    test('copyWith creates new instance with updated fields', () {
      final profile = UserProfile.defaultProfile();
      final updated = profile.copyWith(name: '새 이름', currentWeight: 65);

      expect(updated.name, '새 이름');
      expect(updated.currentWeight, 65);
      expect(updated.height, profile.height); // 변경하지 않은 필드 유지
      expect(updated.age, profile.age);
    });

    test('toJson and fromJson roundtrip', () {
      final profile = UserProfile.defaultProfile();
      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.name, profile.name);
      expect(restored.age, profile.age);
      expect(restored.height, profile.height);
      expect(restored.currentWeight, profile.currentWeight);
      expect(restored.targetWeight, profile.targetWeight);
      expect(restored.gender, profile.gender);
      expect(restored.dailyCalorieGoal, profile.dailyCalorieGoal);
    });
  });
}
