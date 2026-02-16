import 'package:flutter_test/flutter_test.dart';
import 'package:fitmate/data/models/meal_record.dart';

void main() {
  group('MealRecord', () {
    test('MealType has correct labels and emojis', () {
      expect(MealType.breakfast.label, '아침');
      expect(MealType.breakfast.emoji, '🌅');
      expect(MealType.lunch.label, '점심');
      expect(MealType.lunch.emoji, '☀️');
      expect(MealType.dinner.label, '저녁');
      expect(MealType.dinner.emoji, '🌙');
      expect(MealType.snack.label, '간식');
      expect(MealType.snack.emoji, '🍪');
    });

    test('creates MealRecord with required fields', () {
      final meal = MealRecord(
        id: 'test_1',
        date: DateTime(2026, 2, 12, 8, 0),
        mealType: MealType.breakfast,
        name: '닭가슴살 샐러드',
        calories: 350,
        carbs: 15,
        protein: 40,
        fat: 12,
      );

      expect(meal.id, 'test_1');
      expect(meal.name, '닭가슴살 샐러드');
      expect(meal.calories, 350);
      expect(meal.mealType, MealType.breakfast);
    });

    test('copyWith updates only specified fields', () {
      final meal = MealRecord(
        id: 'test_1',
        date: DateTime(2026, 2, 12),
        mealType: MealType.lunch,
        name: '현미밥',
        calories: 260,
        carbs: 56,
        protein: 6,
        fat: 2,
      );

      final updated = meal.copyWith(calories: 300, name: '현미밥 1공기');

      expect(updated.calories, 300);
      expect(updated.name, '현미밥 1공기');
      expect(updated.mealType, MealType.lunch);
      expect(updated.carbs, 56);
    });

    test('toJson and fromJson roundtrip', () {
      final meal = MealRecord(
        id: 'roundtrip_1',
        date: DateTime(2026, 2, 12, 12, 30),
        mealType: MealType.dinner,
        name: '연어 스테이크',
        calories: 400,
        carbs: 10,
        protein: 35,
        fat: 25,
        memo: '맛있었다',
      );

      final json = meal.toJson();
      final restored = MealRecord.fromJson(json);

      expect(restored.id, meal.id);
      expect(restored.name, meal.name);
      expect(restored.calories, meal.calories);
      expect(restored.mealType, meal.mealType);
      expect(restored.carbs, meal.carbs);
      expect(restored.protein, meal.protein);
      expect(restored.fat, meal.fat);
      expect(restored.memo, meal.memo);
    });
  });
}
