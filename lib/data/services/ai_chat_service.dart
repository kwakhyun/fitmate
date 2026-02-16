import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class AiChatService {
  final ApiService _apiService;

  AiChatService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String get _apiKey {
    try {
      return dotenv.env['OPENAI_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  bool get isConfigured =>
      _apiKey.isNotEmpty && _apiKey != 'your_openai_api_key_here';

  Future<String> generateResponse({
    required String userMessage,
    Map<String, dynamic>? context,
  }) async {
    if (!isConfigured) {
      return _generateFallbackResponse(userMessage);
    }

    try {
      final systemPrompt = _buildSystemPrompt(context);

      final response = await _apiService.post(
        ApiConstants.openAiBaseUrl,
        ApiConstants.chatCompletionsEndpoint,
        data: {
          'model': ApiConstants.openAiModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        },
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List;
      if (choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>;
        return message['content'] as String;
      }

      return _generateFallbackResponse(userMessage);
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('insufficient_quota') ||
          errorMsg.contains('RATE_LIMIT')) {
        return '${_generateFallbackResponse(userMessage)}\n\n---\n_💡 현재 AI 서버 사용량이 초과되어 로컬 응답을 표시합니다._';
      }
      return _generateFallbackResponse(userMessage);
    }
  }

  String _buildSystemPrompt(Map<String, dynamic>? context) {
    var prompt = ApiConstants.aiCoachSystemPrompt;

    if (context != null) {
      prompt += '\n\n현재 사용자 데이터:\n';
      if (context['todayCalories'] != null) {
        prompt += '- 오늘 섭취 칼로리: ${context['todayCalories']}kcal\n';
      }
      if (context['calorieGoal'] != null) {
        prompt += '- 일일 칼로리 목표: ${context['calorieGoal']}kcal\n';
      }
      if (context['currentWeight'] != null) {
        prompt += '- 현재 체중: ${context['currentWeight']}kg\n';
      }
      if (context['targetWeight'] != null) {
        prompt += '- 목표 체중: ${context['targetWeight']}kg\n';
      }
      if (context['waterMl'] != null) {
        prompt += '- 오늘 수분 섭취: ${context['waterMl']}ml\n';
      }
      if (context['steps'] != null) {
        prompt += '- 오늘 걸음 수: ${context['steps']}보\n';
      }
      if (context['macros'] != null) {
        final macros = context['macros'] as Map<String, double>;
        prompt +=
            '- 탄수화물: ${macros['carbs']?.toStringAsFixed(0)}g, 단백질: ${macros['protein']?.toStringAsFixed(0)}g, 지방: ${macros['fat']?.toStringAsFixed(0)}g\n';
      }
    }

    return prompt;
  }

  String _generateFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('칼로리') || lowerMessage.contains('열량')) {
      return '📊 칼로리 관리는 다이어트의 핵심이에요!\n\n일반적으로 성인 여성 1,200~1,500kcal, 남성 1,500~1,800kcal을 권장합니다.\n\n대시보드에서 오늘의 섭취량을 확인해보세요. 탄·단·지 비율도 중요한데, 4:3:3 비율을 추천드려요! 💪';
    }

    if (lowerMessage.contains('운동') ||
        lowerMessage.contains('헬스') ||
        lowerMessage.contains('트레이닝')) {
      return '🏃‍♀️ 효과적인 다이어트 운동을 추천해드릴게요!\n\n1. 🚶 유산소 30분 (빠르게 걷기)\n2. 💪 스쿼트 3세트 x 15회\n3. 🧘 플랭크 3세트 x 30초\n4. 🔄 런지 3세트 x 12회\n\n주 3-4회 꾸준히 하시면 효과를 보실 수 있어요!';
    }

    if (lowerMessage.contains('물') || lowerMessage.contains('수분')) {
      return '💧 수분 섭취가 매우 중요해요!\n\n🔹 식전 30분 전에 물 한 잔 → 포만감 증가\n🔹 하루 권장량: 체중(kg) × 30ml\n🔹 카페인 음료는 수분 섭취에 포함하지 마세요\n\n수분이 부족하면 신진대사가 느려져 다이어트에 불리해요! 🎉';
    }

    if (lowerMessage.contains('체중') || lowerMessage.contains('몸무게')) {
      return '⚖️ 건강한 체중 감량 팁!\n\n📈 주당 0.5~1kg 감량이 이상적입니다.\n\n급격한 감량은 요요현상의 원인이 돼요. 꾸준하게 기록하고 추이를 확인하는 것이 가장 중요합니다.\n\n체중 기록 탭에서 변화 추이를 확인해보세요! 🌟';
    }

    if (lowerMessage.contains('간식') || lowerMessage.contains('야식')) {
      return '🍎 건강한 간식 추천!\n\n• 그릭요거트 + 베리류 (130kcal)\n• 삶은 계란 2개 (156kcal)\n• 견과류 한줌 (180kcal)\n• 당근 스틱 + 후무스 (100kcal)\n• 프로틴 쉐이크 (150kcal)\n\n야식이 당길 때는 따뜻한 허브차를 마셔보세요! 🍵';
    }

    if (lowerMessage.contains('안녕') ||
        lowerMessage.contains('하이') ||
        lowerMessage.contains('hi')) {
      return '안녕하세요! 😊\n\n오늘도 건강한 하루 보내고 계신가요?\n\n궁금한 점이 있으시면 편하게 물어보세요:\n• 🍽️ 식단 추천\n• 🏃 운동 추천\n• 📊 칼로리 분석\n• ⚖️ 체중 추이\n• 💧 수분 섭취 팁';
    }

    return '좋은 질문이에요! 💡\n\n건강한 다이어트를 위한 핵심 팁:\n\n1. 🥗 매끼 단백질을 꼭 포함하세요\n2. 💧 하루 2L 이상 수분 섭취\n3. 🛌 7-8시간 수면 유지\n4. 🚶 일일 7,000보 이상 걷기\n5. 📝 식단 기록 습관 유지\n\n더 자세한 내용이 궁금하시면 말씀해주세요!';
  }
}
