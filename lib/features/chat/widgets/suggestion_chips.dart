import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SuggestionChips extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const SuggestionChips({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      '🍽️ 오늘 칼로리 분석',
      '🏃 운동 추천해줘',
      '💧 수분 섭취 팁',
      '⚖️ 체중 변화 분석',
      '🍎 건강한 간식 추천',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: suggestions.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSuggestionTap(s.substring(2).trim()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.colorPrimarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
