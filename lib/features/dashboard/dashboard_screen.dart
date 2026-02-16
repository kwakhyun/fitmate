import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import 'widgets/calorie_ring_card.dart';
import 'widgets/weight_chart_card.dart';
import 'widgets/health_metrics_card.dart';
import 'widgets/today_summary_card.dart';
import 'widgets/quick_actions_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: context.colorSurface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요, ${profile.name.split(' ').first}님 👋',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.colorTextPrimary,
                    ),
                  ),
                  Text(
                    '오늘도 건강한 하루를 시작해볼까요?',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showNotifications(context),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: context.colorPrimarySurface,
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const CalorieRingCard(),
                const SizedBox(height: 16),
                const HealthMetricsCard(),
                const SizedBox(height: 16),
                const TodaySummaryCard(),
                const SizedBox(height: 16),
                const WeightChartCard(),
                const SizedBox(height: 16),
                const QuickActionsCard(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? '좋은 아침이에요!'
        : hour < 18
            ? '오후도 힘내세요!'
            : '오늘 하루 수고하셨어요!';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '알림',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _NotificationItem(
              icon: Icons.wb_sunny_rounded,
              color: AppColors.secondary,
              title: greeting,
              subtitle: '오늘도 건강 관리를 시작해보세요.',
              time: '방금',
            ),
            const SizedBox(height: 12),
            _NotificationItem(
              icon: Icons.water_drop_rounded,
              color: AppColors.info,
              title: '수분 섭취 알림',
              subtitle: '물 한 잔 마시는 건 어떨까요? 💧',
              time: '30분 전',
            ),
            const SizedBox(height: 12),
            _NotificationItem(
              icon: Icons.restaurant_rounded,
              color: AppColors.primary,
              title: '식단 기록 알림',
              subtitle: '오늘의 식사를 기록해주세요!',
              time: '1시간 전',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorSurfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colorTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: context.colorTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
