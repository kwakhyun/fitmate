import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import 'widgets/profile_stat_card.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final records = ref.watch(weightRecordsProvider);
    final initialWeight =
        records.isNotEmpty ? records.first.weight : profile.currentWeight;
    final currentWeight =
        records.isNotEmpty ? records.last.weight : profile.currentWeight;
    final totalToLose = initialWeight - profile.targetWeight;
    final lost = initialWeight - currentWeight;
    final progress =
        totalToLose > 0 ? (lost / totalToLose).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.cardGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.age}세 · ${profile.height.toStringAsFixed(0)}cm · ${profile.gender == "male" ? "남성" : "여성"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${initialWeight.toStringAsFixed(1)}kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  '목표 ${profile.targetWeight.toStringAsFixed(1)}kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              padding: EdgeInsets.zero,
                              lineHeight: 8,
                              percent: progress,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              progressColor: Colors.white,
                              barRadius: const Radius.circular(10),
                              animation: true,
                              animationDuration: 1000,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${lost.toStringAsFixed(1)}kg 감량 완료 · ${(progress * 100).toStringAsFixed(0)}% 달성',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: ProfileStatCard(
                        title: 'BMI',
                        value: profile.bmi.toStringAsFixed(1),
                        subtitle: profile.bmiCategory,
                        icon: Icons.monitor_heart_outlined,
                        color: _getBmiColor(profile.bmi),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStatCard(
                        title: '현재 체중',
                        value: '${currentWeight.toStringAsFixed(1)}kg',
                        subtitle:
                            '${lost > 0 ? "-" : "+"}${lost.abs().toStringAsFixed(1)}kg',
                        icon: Icons.monitor_weight_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ProfileStatCard(
                        title: '일일 목표',
                        value: '${profile.dailyCalorieGoal}',
                        subtitle: 'kcal',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStatCard(
                        title: '남은 기간',
                        value: profile.targetDate != null
                            ? '${profile.targetDate!.difference(DateTime.now()).inDays}'
                            : '-',
                        subtitle: '일',
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SettingsSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 23) return AppColors.success;
    if (bmi < 25) return AppColors.warning;
    return AppColors.error;
  }
}
