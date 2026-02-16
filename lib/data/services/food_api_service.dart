import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/api_constants.dart';
import '../models/meal_record.dart';
import '../repositories/dummy_data.dart';
import 'api_service.dart';

class FoodApiService {
  final ApiService _apiService;
  final Map<String, List<FoodItem>> _aiCache = {};
  final Map<String, List<FoodItem>> _publicApiCache = {};

  FoodApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String get _apiKey {
    try {
      return dotenv.env['OPENAI_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  String get _foodApiKey {
    try {
      return dotenv.env['FOOD_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  bool get _isAiConfigured =>
      _apiKey.isNotEmpty && _apiKey != 'your_openai_api_key_here';

  bool get _isFoodApiConfigured =>
      _foodApiKey.isNotEmpty && _foodApiKey != 'your_data_go_kr_api_key_here';

  Future<List<FoodItem>> searchFood(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _searchLocal('');
    }

    final localResults = _searchLocal(trimmed);

    List<FoodItem> publicResults = [];
    if (_isFoodApiConfigured) {
      publicResults = await _searchPublicApi(trimmed);
    }

    final combinedResults = _mergeResults(localResults, publicResults);

    if (combinedResults.length >= 3) {
      return combinedResults;
    }

    final cacheKey = trimmed.toLowerCase();
    if (_aiCache.containsKey(cacheKey)) {
      return _mergeResults(combinedResults, _aiCache[cacheKey]!);
    }

    if (_isAiConfigured) {
      try {
        final aiResults = await _searchWithAi(trimmed);
        if (aiResults.isNotEmpty) {
          _aiCache[cacheKey] = aiResults;
          return _mergeResults(combinedResults, aiResults);
        }
      } catch (e) {
        debugPrint('AI 음식 검색 실패: $e');
      }
    }

    return combinedResults;
  }

  Future<List<FoodItem>> _searchPublicApi(String query) async {
    final cacheKey = query.trim().toLowerCase();
    if (_publicApiCache.containsKey(cacheKey)) {
      return _publicApiCache[cacheKey]!;
    }

    try {
      final response = await _apiService.get(
        ApiConstants.foodNtrBaseUrl,
        ApiConstants.foodNtrEndpoint,
        queryParams: {
          'serviceKey': _foodApiKey,
          'pageNo': '1',
          'numOfRows': '20',
          'type': 'json',
          'FOOD_NM_KR': query,
        },
      );

      final data = response.data;
      final Map<String, dynamic> jsonData =
          data is String ? jsonDecode(data) : data as Map<String, dynamic>;

      final header = jsonData['header'] as Map<String, dynamic>?;
      if (header == null || header['resultCode'] != '00') {
        debugPrint(
            '공공 API 응답 오류: ${header?['resultCode']} - ${header?['resultMsg']}');
        return [];
      }

      final body = jsonData['body'] as Map<String, dynamic>?;
      if (body == null) return [];

      final items = body['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) return [];

      final results = items
          .map((item) {
            final map = item as Map<String, dynamic>;
            return FoodItem(
              name: _cleanFoodName(map['FOOD_NM_KR'] as String? ?? ''),
              calories:
                  _parseNutrientValue(map['AMT_NUM1']?.toString()).toInt(),
              carbs: _parseNutrientValue(map['AMT_NUM6']?.toString()),
              protein: _parseNutrientValue(map['AMT_NUM3']?.toString()),
              fat: _parseNutrientValue(map['AMT_NUM4']?.toString()),
              servingSize: map['SERVING_SIZE'] as String? ?? '100g',
              source: FoodSource.publicApi,
              isAiGenerated: false,
            );
          })
          .where((item) => item.calories > 0)
          .toList();

      _publicApiCache[cacheKey] = results;
      return results;
    } catch (e) {
      debugPrint('공공데이터 API 검색 실패: $e');
      return [];
    }
  }

  double _parseNutrientValue(String? value) {
    if (value == null || value.isEmpty || value == '-' || value == 'N/A') {
      return 0.0;
    }
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
  }

  String _cleanFoodName(String name) {
    if (name.length > 30) {
      return '${name.substring(0, 27)}...';
    }
    return name.trim();
  }

  Future<List<FoodItem>> _searchWithAi(String query) async {
    final response = await _apiService.post(
      ApiConstants.openAiBaseUrl,
      ApiConstants.chatCompletionsEndpoint,
      data: {
        'model': ApiConstants.openAiModel,
        'messages': [
          {'role': 'system', 'content': ApiConstants.foodAnalysisPrompt},
          {'role': 'user', 'content': query},
        ],
        'max_tokens': 500,
        'temperature': 0.3,
      },
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List;
    if (choices.isEmpty) return [];

    final message = choices[0]['message'] as Map<String, dynamic>;
    final content = (message['content'] as String).trim();

    return _parseAiResponse(content);
  }

  List<FoodItem> _parseAiResponse(String content) {
    try {
      var cleaned = content;
      if (cleaned.contains('```')) {
        cleaned = cleaned
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '');
      }
      cleaned = cleaned.trim();

      final List<dynamic> jsonList = jsonDecode(cleaned);
      return jsonList.map((item) {
        final map = item as Map<String, dynamic>;
        return FoodItem(
          name: map['name'] as String,
          calories: (map['calories'] as num).toInt(),
          carbs: (map['carbs'] as num).toDouble(),
          protein: (map['protein'] as num).toDouble(),
          fat: (map['fat'] as num).toDouble(),
          servingSize: map['servingSize'] as String?,
          source: FoodSource.aiAnalysis,
          isAiGenerated: true,
        );
      }).toList();
    } catch (e) {
      debugPrint('AI 응답 파싱 실패: $e\n원본: $content');
      return [];
    }
  }

  List<FoodItem> _mergeResults(
      List<FoodItem> primary, List<FoodItem> secondary) {
    final merged = [...primary];
    final existingNames = primary.map((f) => f.name.toLowerCase()).toSet();

    for (final item in secondary) {
      if (!existingNames.contains(item.name.toLowerCase())) {
        merged.add(item);
        existingNames.add(item.name.toLowerCase());
      }
    }
    return merged;
  }

  List<FoodItem> _searchLocal(String query) {
    final results = query.isEmpty
        ? DummyData.foodDatabase
        : DummyData.foodDatabase
            .where((f) => (f['name'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

    return results
        .map((f) => FoodItem(
              name: f['name'] as String,
              calories: f['calories'] as int,
              carbs: (f['carbs'] as num).toDouble(),
              protein: (f['protein'] as num).toDouble(),
              fat: (f['fat'] as num).toDouble(),
              source: FoodSource.localDb,
              isAiGenerated: false,
            ))
        .toList();
  }

  void clearCache() {
    _aiCache.clear();
    _publicApiCache.clear();
  }

  Future<FoodItem?> searchByBarcode(String barcode) async {
    try {
      final response = await _apiService.get(
        ApiConstants.openFoodFactsBaseUrl,
        '/api/v0/product/$barcode.json',
      );

      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 1) return null;

      final product = data['product'] as Map<String, dynamic>;
      final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
      final name = product['product_name_ko'] as String? ??
          product['product_name'] as String? ??
          '알 수 없는 제품';

      return FoodItem(
        name: name,
        calories: (nutriments['energy-kcal_100g'] as num?)?.toInt() ?? 0,
        carbs: (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? 0,
        protein: (nutriments['proteins_100g'] as num?)?.toDouble() ?? 0,
        fat: (nutriments['fat_100g'] as num?)?.toDouble() ?? 0,
        brand: product['brands'] as String?,
        servingSize: product['serving_size'] as String? ?? '100g',
        source: FoodSource.barcode,
        isAiGenerated: false,
      );
    } catch (e) {
      debugPrint('바코드 검색 실패: $e');
      return null;
    }
  }

  Map<String, bool> getApiStatus() {
    return {
      'localDb': true,
      'publicApi': _isFoodApiConfigured,
      'aiAnalysis': _isAiConfigured,
      'barcode': true,
    };
  }
}

enum FoodSource {
  localDb,
  publicApi,
  aiAnalysis,
  barcode,
}

class FoodItem {
  final String name;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final String? brand;
  final String? servingSize;

  final bool isAiGenerated;
  final FoodSource source;

  FoodItem({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.brand,
    this.servingSize,
    this.isAiGenerated = false,
    this.source = FoodSource.localDb,
  });

  String get sourceLabel {
    switch (source) {
      case FoodSource.localDb:
        return '내장 DB';
      case FoodSource.publicApi:
        return '식약처';
      case FoodSource.aiAnalysis:
        return 'AI 분석';
      case FoodSource.barcode:
        return '바코드';
    }
  }

  String get sourceEmoji {
    switch (source) {
      case FoodSource.localDb:
        return '📦';
      case FoodSource.publicApi:
        return '🏛️';
      case FoodSource.aiAnalysis:
        return '🤖';
      case FoodSource.barcode:
        return '📷';
    }
  }

  MealRecord toMealRecord({
    required String id,
    required DateTime date,
    required MealType mealType,
  }) {
    return MealRecord(
      id: id,
      date: date,
      mealType: mealType,
      name: name,
      calories: calories,
      carbs: carbs,
      protein: protein,
      fat: fat,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
        'brand': brand,
        'servingSize': servingSize,
        'isAiGenerated': isAiGenerated,
        'source': source.name,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        name: json['name'] as String,
        calories: json['calories'] as int,
        carbs: (json['carbs'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        brand: json['brand'] as String?,
        servingSize: json['servingSize'] as String?,
        isAiGenerated: json['isAiGenerated'] as bool? ?? false,
        source: FoodSource.values.firstWhere(
          (e) => e.name == (json['source'] as String?),
          orElse: () => FoodSource.localDb,
        ),
      );
}
