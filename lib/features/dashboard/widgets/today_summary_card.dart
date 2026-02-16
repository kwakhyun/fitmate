import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../data/models/meal_record.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_rounded,
                    color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 식단',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colorTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...MealType.values.map((type) => _MealTypeRow(mealType: type)),
        ],
      ),
    );
  }
}

class _MealTypeRow extends ConsumerWidget {
  final MealType mealType;
  const _MealTypeRow({required this.mealType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsByTypeProvider(mealType));
    final totalCalories = meals.fold(0, (sum, m) => sum + m.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            mealType.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colorTextPrimary,
                  ),
                ),
                if (meals.isNotEmpty)
                  Text(
                    meals.map((m) => m.name).join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorTextTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    '아직 기록이 없어요',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorTextTertiary,
                    ),
                  ),
              ],
            ),
          ),
          if (meals.isNotEmpty)
            Text(
              '${totalCalories}kcal',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            )
          else
            GestureDetector(
              onTap: () => context.push('/add-meal'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colorPrimarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+ 추가',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
