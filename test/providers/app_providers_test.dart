import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitmate/providers/app_providers.dart';
import 'package:fitmate/data/models/weight_record.dart';
import 'package:fitmate/data/models/meal_record.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    final path =
        '/tmp/hive_provider_test_${DateTime.now().millisecondsSinceEpoch}';
    Hive.init(path);
    await Hive.openBox<String>('user_profile');
    await Hive.openBox<String>('weight_records');
    await Hive.openBox<String>('meal_records');
    await Hive.openBox<String>('daily_health');
    await Hive.openBox<String>('settings');
  });

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('UserProfileNotifier', () {
    test('default profile has valid name', () {
      final profile = container.read(userProfileProvider);
      expect(profile.name.isNotEmpty, true);
    });

    test('updateWeight updates currentWeight', () {
      container.read(userProfileProvider.notifier).updateWeight(65.0);
      final profile = container.read(userProfileProvider);
      expect(profile.currentWeight, 65.0);
    });

    test('updateProfile updates all fields', () {
      final original = container.read(userProfileProvider);
      container.read(userProfileProvider.notifier).updateProfile(
            original.copyWith(name: '테스트 유저', age: 25),
          );
      final updated = container.read(userProfileProvider);
      expect(updated.name, '테스트 유저');
      expect(updated.age, 25);
    });
  });

  group('WeightRecordsNotifier', () {
    test('can add a weight record', () {
      final initialLength = container.read(weightRecordsProvider).length;
      container.read(weightRecordsProvider.notifier).addRecord(
            WeightRecord(
              id: 'test_1',
              date: DateTime.now(),
              weight: 70.0,
            ),
          );
      expect(container.read(weightRecordsProvider).length, initialLength + 1);
    });

    test('can remove a weight record', () {
      container.read(weightRecordsProvider.notifier).addRecord(
            WeightRecord(
              id: 'to_remove',
              date: DateTime.now(),
              weight: 71.0,
            ),
          );
      final lengthBefore = container.read(weightRecordsProvider).length;
      container.read(weightRecordsProvider.notifier).removeRecord('to_remove');
      expect(container.read(weightRecordsProvider).length, lengthBefore - 1);
    });
  });

  group('MealRecordsNotifier', () {
    test('can add a meal', () {
      final initialLength = container.read(mealRecordsProvider).length;
      container.read(mealRecordsProvider.notifier).addMeal(
            MealRecord(
              id: 'meal_test_1',
              date: DateTime.now(),
              mealType: MealType.breakfast,
              name: '테스트 식사',
              calories: 300,
              carbs: 40,
              protein: 20,
              fat: 10,
            ),
          );
      expect(container.read(mealRecordsProvider).length, initialLength + 1);
    });

    test('can remove a meal', () {
      container.read(mealRecordsProvider.notifier).addMeal(
            MealRecord(
              id: 'meal_remove',
              date: DateTime.now(),
              mealType: MealType.lunch,
              name: '삭제할 식사',
              calories: 500,
              carbs: 60,
              protein: 30,
              fat: 15,
            ),
          );
      final lengthBefore = container.read(mealRecordsProvider).length;
      container.read(mealRecordsProvider.notifier).removeMeal('meal_remove');
      expect(container.read(mealRecordsProvider).length, lengthBefore - 1);
    });
  });

  group('DailyHealthNotifier', () {
    test('addWater increases waterMl', () {
      final before = container.read(dailyHealthProvider).waterMl;
      container.read(dailyHealthProvider.notifier).addWater(250);
      expect(container.read(dailyHealthProvider).waterMl, before + 250);
    });

    test('removeWater decreases waterMl', () {
      // First add enough water
      container.read(dailyHealthProvider.notifier).addWater(500);
      final before = container.read(dailyHealthProvider).waterMl;
      container.read(dailyHealthProvider.notifier).removeWater(250);
      expect(container.read(dailyHealthProvider).waterMl, before - 250);
    });

    test('removeWater does not go below zero', () {
      // Remove excessive water
      container.read(dailyHealthProvider.notifier).removeWater(99999);
      expect(container.read(dailyHealthProvider).waterMl, 0);
    });

    test('updateSteps sets steps', () {
      container.read(dailyHealthProvider.notifier).updateSteps(8000);
      expect(container.read(dailyHealthProvider).steps, 8000);
    });

    test('updateSleep sets sleep hours', () {
      container.read(dailyHealthProvider.notifier).updateSleep(7.5);
      expect(container.read(dailyHealthProvider).sleepHours, 7.5);
    });

    test('updateExercise sets exercise minutes', () {
      container.read(dailyHealthProvider.notifier).updateExercise(45);
      expect(container.read(dailyHealthProvider).exerciseMinutes, 45);
    });

    test('updateMood sets mood', () {
      container.read(dailyHealthProvider.notifier).updateMood('happy');
      expect(container.read(dailyHealthProvider).mood, 'happy');
    });
  });

  group('SettingsBoolNotifier', () {
    test('notifications default to true', () {
      expect(container.read(notificationsEnabledProvider), true);
    });

    test('toggle changes value', () {
      container.read(notificationsEnabledProvider.notifier).toggle();
      expect(container.read(notificationsEnabledProvider), false);
      container.read(notificationsEnabledProvider.notifier).toggle();
      expect(container.read(notificationsEnabledProvider), true);
    });

    test('dark mode defaults to false', () {
      expect(container.read(darkModeProvider), false);
    });

    test('setValue sets value directly', () {
      container.read(darkModeProvider.notifier).setValue(true);
      expect(container.read(darkModeProvider), true);
    });
  });

  group('Computed Providers', () {
    test('selectedDateMealsProvider filters by date', () {
      // Set selected date to today
      container.read(selectedDateProvider.notifier).state = DateTime.now();

      // Add a meal for today
      container.read(mealRecordsProvider.notifier).addMeal(
            MealRecord(
              id: 'today_meal',
              date: DateTime.now(),
              mealType: MealType.breakfast,
              name: '오늘 아침',
              calories: 300,
              carbs: 40,
              protein: 20,
              fat: 10,
            ),
          );

      final todayMeals = container.read(selectedDateMealsProvider);
      expect(todayMeals.any((m) => m.id == 'today_meal'), true);

      // Set selected date to tomorrow - should not include today's meal
      container.read(selectedDateProvider.notifier).state =
          DateTime.now().add(const Duration(days: 1));
      final tomorrowMeals = container.read(selectedDateMealsProvider);
      expect(tomorrowMeals.any((m) => m.id == 'today_meal'), false);
    });

    test('mealsByTypeProvider filters by type', () {
      container.read(selectedDateProvider.notifier).state = DateTime.now();

      container.read(mealRecordsProvider.notifier).addMeal(
            MealRecord(
              id: 'snack_type',
              date: DateTime.now(),
              mealType: MealType.snack,
              name: '간식 테스트',
              calories: 100,
              carbs: 15,
              protein: 5,
              fat: 3,
            ),
          );

      final snacks = container.read(mealsByTypeProvider(MealType.snack));
      expect(snacks.any((m) => m.id == 'snack_type'), true);

      final dinners = container.read(mealsByTypeProvider(MealType.dinner));
      expect(dinners.any((m) => m.id == 'snack_type'), false);
    });
  });
}
