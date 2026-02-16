// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fitmate/main.dart';
import 'package:fitmate/features/chat/widgets/suggestion_chips.dart';

void main() {
  setUpAll(() async {
    // Hive 초기화 (테스트용 임시 디렉토리)
    Hive.init('/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}');
    await Hive.openBox<String>('user_profile');
    await Hive.openBox<String>('weight_records');
    await Hive.openBox<String>('meal_records');
    await Hive.openBox<String>('daily_health');
    await Hive.openBox<String>('settings');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('FitMate app smoke test - dashboard loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FitMateApp()),
    );
    await tester.pumpAndSettle();

    // Verify dashboard loads
    expect(find.textContaining('안녕하세요'), findsOneWidget);
  });

  testWidgets('Bottom navigation has 4 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FitMateApp()),
    );
    await tester.pumpAndSettle();

    // Verify bottom nav items
    expect(find.text('대시보드'), findsOneWidget);
    expect(find.text('식단'), findsOneWidget);
    expect(find.text('AI 코치'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });

  testWidgets('Dashboard shows calorie card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FitMateApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 칼로리'), findsOneWidget);
  });

  testWidgets('SuggestionChips displays all suggestions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionChips(
            onSuggestionTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('🍽️ 오늘 칼로리 분석'), findsOneWidget);
    expect(find.text('🏃 운동 추천해줘'), findsOneWidget);
    expect(find.text('💧 수분 섭취 팁'), findsOneWidget);
    expect(find.text('⚖️ 체중 변화 분석'), findsOneWidget);
    expect(find.text('🍎 건강한 간식 추천'), findsOneWidget);
  });
}
