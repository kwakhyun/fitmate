class ApiConstants {
  ApiConstants._();

  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String chatCompletionsEndpoint = '/chat/completions';
  static const String openAiModel = 'gpt-4o-mini';

  static const String nutritionixBaseUrl =
      'https://trackapi.nutritionix.com/v2';
  static const String nutritionixSearchEndpoint = '/search/instant';

  static const String foodNtrBaseUrl =
      'https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02';
  static const String foodNtrEndpoint = '/getFoodNtrCpntDbInq02';

  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;

  static const String aiCoachSystemPrompt = '''
당신은 FitMate AI 코치입니다. 다이어트와 건강 관리 전문 AI 어시스턴트로, 사용자의 맞춤형 건강 관리를 도와줍니다.

역할:
- 식단 분석 및 추천
- 운동 루틴 제안
- 칼로리/영양소 계산 도우미
- 동기부여 코칭
- 체중 관리 팁 제공

규칙:
1. 항상 따뜻하고 격려하는 톤으로 대화하세요
2. 구체적인 수치와 함께 조언하세요
3. 이모지를 적절히 사용하여 친근한 분위기를 만드세요
4. 의학적 진단이나 처방은 하지 마세요
5. 한국어로 답변하세요
6. 답변은 간결하되 유용한 정보를 담으세요 (최대 300자)
''';

  static const String foodAnalysisPrompt = '''
당신은 음식 영양 성분 분석 전문가입니다. 사용자가 입력한 음식의 영양 정보를 JSON 배열로 반환하세요.

규칙:
1. 반드시 유효한 JSON 배열만 반환하세요 (설명 텍스트 없이)
2. 1인분 기준 영양 정보를 제공하세요
3. 한국 음식에 대해 정확한 정보를 제공하세요
4. 검색어와 관련된 음식을 최대 5개까지 반환하세요
5. 칼로리는 정수, 영양소는 소수점 1자리까지 제공하세요

반환 형식:
[
  {
    "name": "음식 이름 (1인분 기준 표기 포함)",
    "calories": 정수,
    "carbs": 소수,
    "protein": 소수,
    "fat": 소수,
    "servingSize": "1인분 기준량 (예: 1공기, 100g, 1개)"
  }
]
''';
}
