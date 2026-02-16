import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

class GoalSettingsSheet extends ConsumerStatefulWidget {
  const GoalSettingsSheet({super.key});

  @override
  ConsumerState<GoalSettingsSheet> createState() => _GoalSettingsSheetState();
}

class _GoalSettingsSheetState extends ConsumerState<GoalSettingsSheet> {
  late TextEditingController _targetWeightController;
  late TextEditingController _calorieGoalController;
  late TextEditingController _waterGoalController;
  late TextEditingController _stepGoalController;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _targetWeightController =
        TextEditingController(text: profile.targetWeight.toStringAsFixed(1));
    _calorieGoalController =
        TextEditingController(text: profile.dailyCalorieGoal.toString());
    _waterGoalController =
        TextEditingController(text: profile.dailyWaterGoalMl.toString());
    _stepGoalController =
        TextEditingController(text: profile.dailyStepGoal.toString());
    _targetDate = profile.targetDate;
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _calorieGoalController.dispose();
    _waterGoalController.dispose();
    _stepGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '목표 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '나만의 건강 목표를 세워보세요 🎯',
              style: TextStyle(
                fontSize: 14,
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildField(
              '목표 체중',
              _targetWeightController,
              const TextInputType.numberWithOptions(decimal: true),
              suffix: 'kg',
              icon: Icons.flag_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildField(
              '일일 칼로리 목표',
              _calorieGoalController,
              TextInputType.number,
              suffix: 'kcal',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    '수분 목표',
                    _waterGoalController,
                    TextInputType.number,
                    suffix: 'ml',
                    icon: Icons.water_drop_rounded,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    '걸음 목표',
                    _stepGoalController,
                    TextInputType.number,
                    suffix: '걸음',
                    icon: Icons.directions_walk_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _save,
                child: const Text(
                  '목표 설정 완료',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    String? suffix,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              '목표 날짜',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: context.colorBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _targetDate != null
                      ? '${_targetDate!.year}년 ${_targetDate!.month}월 ${_targetDate!.day}일'
                      : '날짜를 선택하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: _targetDate != null
                        ? context.colorTextPrimary
                        : context.colorTextTertiary,
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 18, color: context.colorTextTertiary),
              ],
            ),
          ),
        ),
        if (_targetDate != null) ...[
          const SizedBox(height: 4),
          Text(
            'D-${_targetDate!.difference(DateTime.now()).inDays}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
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
      setState(() => _targetDate = picked);
    }
  }

  void _save() {
    final targetWeight = double.tryParse(_targetWeightController.text);
    final calorieGoal = int.tryParse(_calorieGoalController.text);
    final waterGoal = int.tryParse(_waterGoalController.text);
    final stepGoal = int.tryParse(_stepGoalController.text);

    if (targetWeight == null ||
        calorieGoal == null ||
        waterGoal == null ||
        stepGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 올바르게 입력해주세요')),
      );
      return;
    }

    final profile = ref.read(userProfileProvider);
    ref.read(userProfileProvider.notifier).updateProfile(
          profile.copyWith(
            targetWeight: targetWeight,
            dailyCalorieGoal: calorieGoal,
            dailyWaterGoalMl: waterGoal,
            dailyStepGoal: stepGoal,
            targetDate: _targetDate,
          ),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('목표가 업데이트되었습니다 🎯'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
