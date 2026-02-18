import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/meal_record.dart';
import '../../providers/app_providers.dart';
import 'widgets/meal_type_section.dart';
import 'widgets/nutrition_summary_bar.dart';

class MealScreen extends ConsumerWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCalories = ref.watch(todayCaloriesProvider);
    final profile = ref.watch(userProfileProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isToday = _isToday(selectedDate);

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              '식단 기록',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            if (!isToday)
              Text(
                DateFormat('M월 d일 (E)', 'ko').format(selectedDate),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colorTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded, size: 20),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.primary,
                          ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isToday)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: context.colorPrimarySurface,
              child: Row(
                children: [
                  Text(
                    DateFormat('yyyy년 M월 d일').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref.read(selectedDateProvider.notifier).state =
                        DateTime.now(),
                    child: const Text(
                      '오늘로 돌아가기',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          NutritionSummaryBar(
            consumed: totalCalories,
            goal: profile.dailyCalorieGoal,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...MealType.values.map((type) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MealTypeSection(mealType: type),
                    )),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-meal'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
