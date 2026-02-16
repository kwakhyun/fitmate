import 'package:flutter_test/flutter_test.dart';
import 'package:fitmate/data/services/ai_chat_service.dart';

void main() {
  group('AiChatService', () {
    late AiChatService service;

    setUp(() {
      service = AiChatService();
    });

    test('isConfigured returns false when API key is not set', () {
      // .env에 기본값이 설정되어 있으므로 false
      expect(service.isConfigured, isFalse);
    });

    test('fallback response for calorie keyword', () async {
      final response = await service.generateResponse(
        userMessage: '오늘 칼로리 얼마나 먹었어?',
      );

      expect(response, contains('칼로리'));
      expect(response, isNotEmpty);
    });

    test('fallback response for exercise keyword', () async {
      final response = await service.generateResponse(
        userMessage: '운동 추천해줘',
      );

      expect(response, contains('운동'));
    });

    test('fallback response for water keyword', () async {
      final response = await service.generateResponse(
        userMessage: '수분 섭취 팁 알려줘',
      );

      expect(response, contains('수분'));
    });

    test('fallback response for weight keyword', () async {
      final response = await service.generateResponse(
        userMessage: '체중 변화 분석',
      );

      expect(response, contains('체중'));
    });

    test('fallback response for snack keyword', () async {
      final response = await service.generateResponse(
        userMessage: '건강한 간식 추천',
      );

      expect(response, contains('간식'));
    });

    test('fallback response for greeting', () async {
      final response = await service.generateResponse(
        userMessage: '안녕하세요',
      );

      expect(response, contains('안녕'));
    });

    test('fallback response for unknown input', () async {
      final response = await service.generateResponse(
        userMessage: '아무 말이나 해볼게',
      );

      expect(response, isNotEmpty);
      expect(response, contains('다이어트'));
    });

    test('generateResponse accepts context parameter', () async {
      final response = await service.generateResponse(
        userMessage: '칼로리 분석해줘',
        context: {
          'todayCalories': 1200,
          'calorieGoal': 1500,
          'currentWeight': 65.0,
          'targetWeight': 58.0,
        },
      );

      expect(response, isNotEmpty);
    });
  });
}
