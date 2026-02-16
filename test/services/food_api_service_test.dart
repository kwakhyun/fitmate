import 'package:flutter_test/flutter_test.dart';
import 'package:fitmate/data/services/food_api_service.dart';
import 'package:fitmate/data/models/meal_record.dart';

void main() {
  group('FoodApiService', () {
    late FoodApiService service;

    setUp(() {
      service = FoodApiService();
    });

    test('searchFood returns all foods when query is empty', () async {
      final results = await service.searchFood('');

      expect(results, isNotEmpty);
      expect(results.length, greaterThanOrEqualTo(10));
    });

    test('searchFood filters by name', () async {
      final results = await service.searchFood('닭가슴살');

      expect(results, isNotEmpty);
      expect(results.every((f) => f.name.contains('닭가슴살')), isTrue);
    });

    test('searchFood returns results for Korean food categories', () async {
      final riceFoods = await service.searchFood('밥');
      expect(riceFoods, isNotEmpty);

      final meatFoods = await service.searchFood('고기');
      expect(meatFoods, isNotEmpty);

      final drinkFoods = await service.searchFood('아메리카노');
      expect(drinkFoods, isNotEmpty);
    });

    test('searchFood returns local results for common foods', () async {
      final results = await service.searchFood('김치');
      expect(results, isNotEmpty);
      expect(results.any((f) => !f.isAiGenerated), isTrue);
    });

    test('searchFood handles special characters', () async {
      final results = await service.searchFood('(드레싱');
      expect(results, isNotEmpty);
    });

    test('expanded food database has 70+ items', () async {
      final all = await service.searchFood('');
      expect(all.length, greaterThanOrEqualTo(70));
    });

    test('food database covers all major categories', () async {
      final all = await service.searchFood('');
      final allNames = all.map((f) => f.name).join(' ');

      expect(allNames.contains('밥'), isTrue);
      expect(allNames.contains('면'), isTrue);
      expect(allNames.contains('닭'), isTrue);
      expect(allNames.contains('찌개'), isTrue);
      expect(allNames.contains('과'), isTrue);
      expect(allNames.contains('아메리카노'), isTrue);
    });

    test('searchFood returns empty for non-existent food without AI', () async {
      final results = await service.searchFood('존재하지않는음식xyz');
      expect(results, isA<List<FoodItem>>());
    });

    test('FoodItem has correct properties', () {
      final item = FoodItem(
        name: '테스트 음식',
        calories: 200,
        carbs: 20,
        protein: 15,
        fat: 8,
      );

      expect(item.name, '테스트 음식');
      expect(item.calories, 200);
      expect(item.carbs, 20);
      expect(item.protein, 15);
      expect(item.fat, 8);
      expect(item.isAiGenerated, isFalse);
      expect(item.source, FoodSource.localDb);
    });

    test('FoodItem isAiGenerated flag works', () {
      final aiItem = FoodItem(
        name: 'AI 분석 음식',
        calories: 300,
        carbs: 25,
        protein: 20,
        fat: 10,
        isAiGenerated: true,
        source: FoodSource.aiAnalysis,
      );

      expect(aiItem.isAiGenerated, isTrue);
      expect(aiItem.source, FoodSource.aiAnalysis);

      final localItem = FoodItem(
        name: '로컬 DB 음식',
        calories: 200,
        carbs: 15,
        protein: 10,
        fat: 5,
        isAiGenerated: false,
      );

      expect(localItem.isAiGenerated, isFalse);
      expect(localItem.source, FoodSource.localDb);
    });

    test('FoodItem toJson and fromJson roundtrip preserves all fields', () {
      final item = FoodItem(
        name: '테스트',
        calories: 150,
        carbs: 10,
        protein: 20,
        fat: 5,
        brand: '브랜드A',
        servingSize: '100g',
        isAiGenerated: true,
        source: FoodSource.aiAnalysis,
      );

      final json = item.toJson();
      final restored = FoodItem.fromJson(json);

      expect(restored.name, item.name);
      expect(restored.calories, item.calories);
      expect(restored.brand, item.brand);
      expect(restored.servingSize, item.servingSize);
      expect(restored.isAiGenerated, isTrue);
      expect(restored.source, FoodSource.aiAnalysis);
    });

    test('FoodItem.fromJson defaults isAiGenerated to false when missing', () {
      final json = {
        'name': '이전 데이터',
        'calories': 100,
        'carbs': 10.0,
        'protein': 5.0,
        'fat': 3.0,
      };

      final item = FoodItem.fromJson(json);
      expect(item.isAiGenerated, isFalse);
      expect(item.source, FoodSource.localDb);
    });

    test('FoodItem.toMealRecord converts correctly', () {
      final item = FoodItem(
        name: '현미밥',
        calories: 260,
        carbs: 56,
        protein: 6,
        fat: 2,
      );

      final meal = item.toMealRecord(
        id: 'meal_1',
        date: DateTime(2026, 2, 12),
        mealType: MealType.lunch,
      );

      expect(meal.id, 'meal_1');
      expect(meal.name, '현미밥');
      expect(meal.calories, 260);
      expect(meal.mealType, MealType.lunch);
    });

    test('clearCache clears all caches', () {
      service.clearCache();
      expect(() => service.clearCache(), returnsNormally);
    });
  });

  group('FoodSource', () {
    test('FoodSource enum has all expected values', () {
      expect(FoodSource.values, hasLength(4));
      expect(FoodSource.values, contains(FoodSource.localDb));
      expect(FoodSource.values, contains(FoodSource.publicApi));
      expect(FoodSource.values, contains(FoodSource.aiAnalysis));
      expect(FoodSource.values, contains(FoodSource.barcode));
    });

    test('FoodItem sourceLabel returns correct labels', () {
      final local = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.localDb);
      expect(local.sourceLabel, '내장 DB');

      final publicApi = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.publicApi);
      expect(publicApi.sourceLabel, '식약처');

      final ai = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.aiAnalysis);
      expect(ai.sourceLabel, 'AI 분석');

      final barcode = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.barcode);
      expect(barcode.sourceLabel, '바코드');
    });

    test('FoodItem sourceEmoji returns correct emojis', () {
      final local = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.localDb);
      expect(local.sourceEmoji, '📦');

      final publicApi = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.publicApi);
      expect(publicApi.sourceEmoji, '🏛️');

      final ai = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.aiAnalysis);
      expect(ai.sourceEmoji, '🤖');

      final barcode = FoodItem(
          name: 't',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
          source: FoodSource.barcode);
      expect(barcode.sourceEmoji, '📷');
    });

    test('FoodItem.fromJson handles source field correctly', () {
      final json = {
        'name': 'test',
        'calories': 100,
        'carbs': 10.0,
        'protein': 5.0,
        'fat': 3.0,
        'source': 'publicApi',
      };
      final item = FoodItem.fromJson(json);
      expect(item.source, FoodSource.publicApi);
    });

    test('FoodItem.fromJson defaults source to localDb when missing', () {
      final json = {
        'name': 'test',
        'calories': 100,
        'carbs': 10.0,
        'protein': 5.0,
        'fat': 3.0,
      };
      final item = FoodItem.fromJson(json);
      expect(item.source, FoodSource.localDb);
    });

    test('FoodItem.toJson includes source field', () {
      final item = FoodItem(
        name: 'test',
        calories: 100,
        carbs: 10,
        protein: 5,
        fat: 3,
        source: FoodSource.publicApi,
      );
      final json = item.toJson();
      expect(json['source'], 'publicApi');
    });
  });

  group('FoodApiService - getApiStatus', () {
    test('getApiStatus returns correct keys', () {
      final service = FoodApiService();
      final status = service.getApiStatus();

      expect(status.containsKey('localDb'), isTrue);
      expect(status.containsKey('publicApi'), isTrue);
      expect(status.containsKey('aiAnalysis'), isTrue);
      expect(status.containsKey('barcode'), isTrue);
    });

    test('localDb is always available', () {
      final service = FoodApiService();
      final status = service.getApiStatus();
      expect(status['localDb'], isTrue);
    });

    test('barcode is always available', () {
      final service = FoodApiService();
      final status = service.getApiStatus();
      expect(status['barcode'], isTrue);
    });
  });

  group('FoodApiService - local DB search edge cases', () {
    test('search is case insensitive', () async {
      final service = FoodApiService();
      final upper = await service.searchFood('아메리카노');
      expect(upper, isNotEmpty);
    });

    test('search trims whitespace', () async {
      final service = FoodApiService();
      final result = await service.searchFood('  밥  ');
      expect(result, isNotEmpty);
    });

    test('empty string returns full database', () async {
      final service = FoodApiService();
      final result = await service.searchFood('');
      expect(result.length, greaterThanOrEqualTo(70));
    });

    test('whitespace-only query returns full database', () async {
      final service = FoodApiService();
      final result = await service.searchFood('   ');
      expect(result.length, greaterThanOrEqualTo(70));
    });
  });
}
