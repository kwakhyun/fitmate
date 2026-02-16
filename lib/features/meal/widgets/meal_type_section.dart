import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/meal_record.dart';
import '../../../providers/app_providers.dart';

class MealTypeSection extends ConsumerWidget {
  final MealType mealType;
  const MealTypeSection({super.key, required this.mealType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsByTypeProvider(mealType));
    final totalCalories = meals.fold(0, (sum, m) => sum + m.calories);

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      mealType.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.colorTextPrimary,
                        ),
                      ),
                      Text(
                        meals.isEmpty
                            ? '아직 기록이 없어요'
                            : '${meals.length}개 항목 · ${totalCalories}kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colorTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalCalories > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${totalCalories}kcal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _getColor(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (meals.isNotEmpty) ...[
            const Divider(height: 0),
            ...meals.map((meal) => _MealItem(
                  meal: meal,
                  onDismissed: () => ref
                      .read(mealRecordsProvider.notifier)
                      .removeMeal(meal.id),
                )),
          ],
        ],
      ),
    );
  }

  Color _getColor() {
    switch (mealType) {
      case MealType.breakfast:
        return AppColors.secondary;
      case MealType.lunch:
        return AppColors.primary;
      case MealType.dinner:
        return AppColors.accent;
      case MealType.snack:
        return AppColors.warning;
    }
  }
}

class _MealItem extends StatelessWidget {
  final MealRecord meal;
  final VoidCallback onDismissed;

  const _MealItem({
    required this.meal,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '탄 ${meal.carbs.toStringAsFixed(0)}g · 단 ${meal.protein.toStringAsFixed(0)}g · 지 ${meal.fat.toStringAsFixed(0)}g',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colorTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${meal.calories}kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
