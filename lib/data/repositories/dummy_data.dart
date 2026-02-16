import 'dart:math';
import '../models/weight_record.dart';
import '../models/meal_record.dart';
import '../models/daily_health.dart';

class DummyData {
  static final _random = Random(42);

  static List<WeightRecord> generateWeightRecords() {
    final now = DateTime.now();
    final records = <WeightRecord>[];
    double weight = 72.0;

    for (int i = 60; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      weight -= (_random.nextDouble() * 0.3 - 0.05);
      weight = weight.clamp(58.0, 72.0);
      records.add(WeightRecord(
        id: 'w_$i',
        date: date,
        weight: double.parse(weight.toStringAsFixed(1)),
        bodyFat: double.parse((25.0 - (72.0 - weight) * 0.5)
            .clamp(18.0, 28.0)
            .toStringAsFixed(1)),
        muscleMass:
            double.parse((26.0 + _random.nextDouble() * 2).toStringAsFixed(1)),
      ));
    }
    return records;
  }

  static List<MealRecord> generateTodayMeals() {
    final now = DateTime.now();
    return [
      MealRecord(
        id: 'm_1',
        date: DateTime(now.year, now.month, now.day, 8, 0),
        mealType: MealType.breakfast,
        name: '그릭요거트 & 그래놀라',
        calories: 320,
        carbs: 35,
        protein: 18,
        fat: 12,
      ),
      MealRecord(
        id: 'm_2',
        date: DateTime(now.year, now.month, now.day, 8, 15),
        mealType: MealType.breakfast,
        name: '아메리카노',
        calories: 10,
        carbs: 2,
        protein: 0,
        fat: 0,
      ),
      MealRecord(
        id: 'm_3',
        date: DateTime(now.year, now.month, now.day, 12, 30),
        mealType: MealType.lunch,
        name: '닭가슴살 샐러드',
        calories: 380,
        carbs: 15,
        protein: 42,
        fat: 16,
      ),
      MealRecord(
        id: 'm_4',
        date: DateTime(now.year, now.month, now.day, 12, 30),
        mealType: MealType.lunch,
        name: '현미밥 (반공기)',
        calories: 130,
        carbs: 28,
        protein: 3,
        fat: 1,
      ),
      MealRecord(
        id: 'm_5',
        date: DateTime(now.year, now.month, now.day, 15, 0),
        mealType: MealType.snack,
        name: '프로틴 바',
        calories: 190,
        carbs: 20,
        protein: 15,
        fat: 7,
      ),
    ];
  }

  static DailyHealth generateTodayHealth() {
    final now = DateTime.now();
    return DailyHealth(
      id: 'h_today',
      date: DateTime(now.year, now.month, now.day),
      waterMl: 1500,
      steps: 7234,
      sleepHours: 7.5,
      exerciseMinutes: 45,
      mood: '😊',
    );
  }

  static List<DailyHealth> generateWeeklyHealth() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DailyHealth(
        id: 'h_$i',
        date: DateTime(date.year, date.month, date.day),
        waterMl: 1000 + _random.nextInt(1500),
        steps: 3000 + _random.nextInt(10000),
        sleepHours: 5.5 + _random.nextDouble() * 3,
        exerciseMinutes: _random.nextInt(90),
        mood: ['😊', '😐', '😴', '💪', '😃'][_random.nextInt(5)],
      );
    });
  }

  static final List<Map<String, dynamic>> foodDatabase = [
    // ── 밥·곡류 ──
    {
      'name': '흰쌀밥 1공기',
      'calories': 300,
      'carbs': 66.0,
      'protein': 5.0,
      'fat': 0.5,
      'category': '밥'
    },
    {
      'name': '현미밥 1공기',
      'calories': 260,
      'carbs': 56.0,
      'protein': 6.0,
      'fat': 2.0,
      'category': '밥'
    },
    {
      'name': '잡곡밥 1공기',
      'calories': 280,
      'carbs': 60.0,
      'protein': 7.0,
      'fat': 1.5,
      'category': '밥'
    },
    {
      'name': '볶음밥 1인분',
      'calories': 450,
      'carbs': 65.0,
      'protein': 12.0,
      'fat': 15.0,
      'category': '밥'
    },
    {
      'name': '김밥 1줄',
      'calories': 380,
      'carbs': 55.0,
      'protein': 10.0,
      'fat': 12.0,
      'category': '밥'
    },
    {
      'name': '비빔밥 1인분',
      'calories': 520,
      'carbs': 72.0,
      'protein': 18.0,
      'fat': 16.0,
      'category': '밥'
    },
    {
      'name': '오트밀 1컵',
      'calories': 158,
      'carbs': 27.0,
      'protein': 6.0,
      'fat': 3.0,
      'category': '밥'
    },
    // ── 면류 ──
    {
      'name': '라면 1봉',
      'calories': 500,
      'carbs': 75.0,
      'protein': 10.0,
      'fat': 18.0,
      'category': '면'
    },
    {
      'name': '짜장면 1인분',
      'calories': 650,
      'carbs': 85.0,
      'protein': 15.0,
      'fat': 25.0,
      'category': '면'
    },
    {
      'name': '짬뽕 1인분',
      'calories': 520,
      'carbs': 70.0,
      'protein': 20.0,
      'fat': 17.0,
      'category': '면'
    },
    {
      'name': '칼국수 1인분',
      'calories': 420,
      'carbs': 65.0,
      'protein': 15.0,
      'fat': 10.0,
      'category': '면'
    },
    {
      'name': '냉면 1인분',
      'calories': 480,
      'carbs': 80.0,
      'protein': 12.0,
      'fat': 8.0,
      'category': '면'
    },
    {
      'name': '파스타(토마토) 1인분',
      'calories': 520,
      'carbs': 70.0,
      'protein': 16.0,
      'fat': 18.0,
      'category': '면'
    },
    {
      'name': '우동 1인분',
      'calories': 400,
      'carbs': 60.0,
      'protein': 12.0,
      'fat': 10.0,
      'category': '면'
    },
    // ── 고기·생선 ──
    {
      'name': '닭가슴살 100g',
      'calories': 165,
      'carbs': 0.0,
      'protein': 31.0,
      'fat': 3.6,
      'category': '고기'
    },
    {
      'name': '소고기(등심) 100g',
      'calories': 250,
      'carbs': 0.0,
      'protein': 26.0,
      'fat': 16.0,
      'category': '고기'
    },
    {
      'name': '돼지고기(삼겹살) 100g',
      'calories': 330,
      'carbs': 0.0,
      'protein': 18.0,
      'fat': 28.0,
      'category': '고기'
    },
    {
      'name': '연어 100g',
      'calories': 208,
      'carbs': 0.0,
      'protein': 20.0,
      'fat': 13.0,
      'category': '생선'
    },
    {
      'name': '고등어구이 1토막',
      'calories': 180,
      'carbs': 0.0,
      'protein': 20.0,
      'fat': 11.0,
      'category': '생선'
    },
    {
      'name': '참치회 100g',
      'calories': 130,
      'carbs': 0.0,
      'protein': 28.0,
      'fat': 1.5,
      'category': '생선'
    },
    {
      'name': '새우 100g',
      'calories': 85,
      'carbs': 0.0,
      'protein': 18.0,
      'fat': 1.0,
      'category': '생선'
    },
    // ── 한식 반찬 ──
    {
      'name': '김치찌개 1인분',
      'calories': 200,
      'carbs': 10.0,
      'protein': 14.0,
      'fat': 12.0,
      'category': '찌개'
    },
    {
      'name': '된장찌개 1인분',
      'calories': 150,
      'carbs': 12.0,
      'protein': 10.0,
      'fat': 7.0,
      'category': '찌개'
    },
    {
      'name': '순두부찌개 1인분',
      'calories': 180,
      'carbs': 8.0,
      'protein': 12.0,
      'fat': 10.0,
      'category': '찌개'
    },
    {
      'name': '제육볶음 1인분',
      'calories': 350,
      'carbs': 15.0,
      'protein': 22.0,
      'fat': 22.0,
      'category': '반찬'
    },
    {
      'name': '불고기 1인분',
      'calories': 310,
      'carbs': 12.0,
      'protein': 28.0,
      'fat': 16.0,
      'category': '반찬'
    },
    {
      'name': '잡채 1인분',
      'calories': 270,
      'carbs': 35.0,
      'protein': 8.0,
      'fat': 10.0,
      'category': '반찬'
    },
    {
      'name': '김치 1접시',
      'calories': 25,
      'carbs': 4.0,
      'protein': 1.5,
      'fat': 0.3,
      'category': '반찬'
    },
    {
      'name': '계란찜 1인분',
      'calories': 120,
      'carbs': 2.0,
      'protein': 10.0,
      'fat': 8.0,
      'category': '반찬'
    },
    {
      'name': '시금치나물 1접시',
      'calories': 35,
      'carbs': 3.0,
      'protein': 3.0,
      'fat': 1.5,
      'category': '반찬'
    },
    {
      'name': '콩나물무침 1접시',
      'calories': 40,
      'carbs': 4.0,
      'protein': 4.0,
      'fat': 1.0,
      'category': '반찬'
    },
    // ── 분식·간식 ──
    {
      'name': '떡볶이 1인분',
      'calories': 380,
      'carbs': 70.0,
      'protein': 8.0,
      'fat': 8.0,
      'category': '분식'
    },
    {
      'name': '순대 1인분',
      'calories': 320,
      'carbs': 35.0,
      'protein': 14.0,
      'fat': 14.0,
      'category': '분식'
    },
    {
      'name': '튀김(모듬) 1인분',
      'calories': 400,
      'carbs': 40.0,
      'protein': 10.0,
      'fat': 22.0,
      'category': '분식'
    },
    {
      'name': '만두(5개)',
      'calories': 280,
      'carbs': 30.0,
      'protein': 12.0,
      'fat': 12.0,
      'category': '분식'
    },
    {
      'name': '토스트 1개',
      'calories': 320,
      'carbs': 35.0,
      'protein': 12.0,
      'fat': 14.0,
      'category': '분식'
    },
    // ── 빵·베이커리 ──
    {
      'name': '식빵 1장',
      'calories': 80,
      'carbs': 14.0,
      'protein': 3.0,
      'fat': 1.0,
      'category': '빵'
    },
    {
      'name': '크로아상 1개',
      'calories': 230,
      'carbs': 26.0,
      'protein': 5.0,
      'fat': 12.0,
      'category': '빵'
    },
    {
      'name': '베이글 1개',
      'calories': 270,
      'carbs': 53.0,
      'protein': 10.0,
      'fat': 1.5,
      'category': '빵'
    },
    // ── 달걀·유제품 ──
    {
      'name': '계란 1개',
      'calories': 78,
      'carbs': 0.6,
      'protein': 6.0,
      'fat': 5.3,
      'category': '유제품'
    },
    {
      'name': '계란 프라이 1개',
      'calories': 110,
      'carbs': 0.6,
      'protein': 6.0,
      'fat': 9.0,
      'category': '유제품'
    },
    {
      'name': '그릭요거트 1컵',
      'calories': 130,
      'carbs': 6.0,
      'protein': 17.0,
      'fat': 4.0,
      'category': '유제품'
    },
    {
      'name': '우유 1잔 (200ml)',
      'calories': 120,
      'carbs': 10.0,
      'protein': 6.0,
      'fat': 6.0,
      'category': '유제품'
    },
    {
      'name': '치즈 1장',
      'calories': 60,
      'carbs': 1.0,
      'protein': 4.0,
      'fat': 4.5,
      'category': '유제품'
    },
    {
      'name': '두부 반모',
      'calories': 94,
      'carbs': 2.0,
      'protein': 10.0,
      'fat': 5.0,
      'category': '유제품'
    },
    // ── 과일 ──
    {
      'name': '바나나 1개',
      'calories': 105,
      'carbs': 27.0,
      'protein': 1.3,
      'fat': 0.4,
      'category': '과일'
    },
    {
      'name': '사과 1개',
      'calories': 95,
      'carbs': 25.0,
      'protein': 0.5,
      'fat': 0.3,
      'category': '과일'
    },
    {
      'name': '귤 1개',
      'calories': 40,
      'carbs': 10.0,
      'protein': 0.6,
      'fat': 0.2,
      'category': '과일'
    },
    {
      'name': '딸기 10개',
      'calories': 50,
      'carbs': 12.0,
      'protein': 1.0,
      'fat': 0.5,
      'category': '과일'
    },
    {
      'name': '아보카도 반개',
      'calories': 120,
      'carbs': 6.0,
      'protein': 1.5,
      'fat': 11.0,
      'category': '과일'
    },
    {
      'name': '블루베리 1컵',
      'calories': 85,
      'carbs': 21.0,
      'protein': 1.0,
      'fat': 0.5,
      'category': '과일'
    },
    // ── 채소·샐러드 ──
    {
      'name': '샐러드(드레싱 포함)',
      'calories': 150,
      'carbs': 12.0,
      'protein': 3.0,
      'fat': 10.0,
      'category': '채소'
    },
    {
      'name': '고구마 1개',
      'calories': 130,
      'carbs': 30.0,
      'protein': 2.0,
      'fat': 0.1,
      'category': '채소'
    },
    {
      'name': '감자 1개',
      'calories': 110,
      'carbs': 25.0,
      'protein': 2.5,
      'fat': 0.1,
      'category': '채소'
    },
    {
      'name': '옥수수 1개',
      'calories': 130,
      'carbs': 27.0,
      'protein': 4.0,
      'fat': 1.5,
      'category': '채소'
    },
    // ── 음료 ──
    {
      'name': '아메리카노',
      'calories': 10,
      'carbs': 2.0,
      'protein': 0.3,
      'fat': 0.0,
      'category': '음료'
    },
    {
      'name': '카페라떼',
      'calories': 150,
      'carbs': 12.0,
      'protein': 8.0,
      'fat': 8.0,
      'category': '음료'
    },
    {
      'name': '녹차라떼',
      'calories': 190,
      'carbs': 28.0,
      'protein': 7.0,
      'fat': 5.0,
      'category': '음료'
    },
    {
      'name': '스무디 1잔',
      'calories': 220,
      'carbs': 45.0,
      'protein': 3.0,
      'fat': 2.0,
      'category': '음료'
    },
    {
      'name': '콜라 1캔',
      'calories': 140,
      'carbs': 39.0,
      'protein': 0.0,
      'fat': 0.0,
      'category': '음료'
    },
    {
      'name': '오렌지주스 1잔',
      'calories': 110,
      'carbs': 26.0,
      'protein': 2.0,
      'fat': 0.0,
      'category': '음료'
    },
    // ── 건강식 ──
    {
      'name': '프로틴 쉐이크',
      'calories': 150,
      'carbs': 5.0,
      'protein': 25.0,
      'fat': 3.0,
      'category': '건강식'
    },
    {
      'name': '프로틴 바',
      'calories': 190,
      'carbs': 20.0,
      'protein': 15.0,
      'fat': 7.0,
      'category': '건강식'
    },
    {
      'name': '견과류 한줌',
      'calories': 180,
      'carbs': 6.0,
      'protein': 5.0,
      'fat': 16.0,
      'category': '건강식'
    },
    {
      'name': '닭가슴살 샐러드',
      'calories': 250,
      'carbs': 10.0,
      'protein': 35.0,
      'fat': 8.0,
      'category': '건강식'
    },
    {
      'name': '곤약젤리 1개',
      'calories': 10,
      'carbs': 3.0,
      'protein': 0.0,
      'fat': 0.0,
      'category': '건강식'
    },
    // ── 외식·패스트푸드 ──
    {
      'name': '치킨(후라이드) 1조각',
      'calories': 250,
      'carbs': 8.0,
      'protein': 18.0,
      'fat': 16.0,
      'category': '외식'
    },
    {
      'name': '피자 1조각',
      'calories': 300,
      'carbs': 35.0,
      'protein': 12.0,
      'fat': 12.0,
      'category': '외식'
    },
    {
      'name': '햄버거 1개',
      'calories': 450,
      'carbs': 40.0,
      'protein': 22.0,
      'fat': 22.0,
      'category': '외식'
    },
    {
      'name': '감자튀김(중)',
      'calories': 340,
      'carbs': 44.0,
      'protein': 4.0,
      'fat': 16.0,
      'category': '외식'
    },
    {
      'name': '돈까스 1인분',
      'calories': 550,
      'carbs': 45.0,
      'protein': 25.0,
      'fat': 28.0,
      'category': '외식'
    },
    {
      'name': '초밥(8피스)',
      'calories': 350,
      'carbs': 52.0,
      'protein': 18.0,
      'fat': 6.0,
      'category': '외식'
    },
    {
      'name': '샌드위치 1개',
      'calories': 350,
      'carbs': 38.0,
      'protein': 16.0,
      'fat': 14.0,
      'category': '외식'
    },
    {
      'name': '타코 1개',
      'calories': 210,
      'carbs': 20.0,
      'protein': 10.0,
      'fat': 10.0,
      'category': '외식'
    },
    // ── 디저트 ──
    {
      'name': '아이스크림 1스쿱',
      'calories': 140,
      'carbs': 17.0,
      'protein': 2.0,
      'fat': 7.0,
      'category': '디저트'
    },
    {
      'name': '초콜릿 1줄(30g)',
      'calories': 160,
      'carbs': 17.0,
      'protein': 2.0,
      'fat': 9.0,
      'category': '디저트'
    },
    {
      'name': '케이크 1조각',
      'calories': 350,
      'carbs': 45.0,
      'protein': 4.0,
      'fat': 17.0,
      'category': '디저트'
    },
    {
      'name': '마카롱 1개',
      'calories': 100,
      'carbs': 14.0,
      'protein': 1.5,
      'fat': 4.0,
      'category': '디저트'
    },
    {
      'name': '붕어빵 1개',
      'calories': 150,
      'carbs': 28.0,
      'protein': 3.0,
      'fat': 3.0,
      'category': '디저트'
    },
  ];
}
