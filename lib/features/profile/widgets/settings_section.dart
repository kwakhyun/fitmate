import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import 'edit_profile_sheet.dart';
import 'goal_settings_sheet.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final darkMode = ref.watch(darkModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              '설정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: '프로필 편집',
            onTap: () => _showEditProfile(context),
          ),
          _SettingsTile(
            icon: Icons.flag_outlined,
            title: '목표 설정',
            onTap: () => _showGoalSettings(context),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (_) =>
                  ref.read(notificationsEnabledProvider.notifier).toggle(),
              activeThumbColor: AppColors.primary,
            ),
            onTap: () =>
                ref.read(notificationsEnabledProvider.notifier).toggle(),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: '다크 모드',
            trailing: Switch(
              value: darkMode,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
              activeThumbColor: AppColors.primary,
            ),
            onTap: () => ref.read(darkModeProvider.notifier).toggle(),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: '언어',
            trailing: Text(
              '한국어',
              style: TextStyle(
                fontSize: 14,
                color: context.colorTextTertiary,
              ),
            ),
            onTap: () => _showLanguageInfo(context),
          ),
          const Divider(height: 0, indent: 56),
          _SettingsTile(
            icon: Icons.cloud_outlined,
            title: 'API 연결 상태',
            onTap: () => _showApiStatus(context, ref),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: '데이터 내보내기',
            onTap: () => _exportData(context, ref),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: '앱 정보',
            trailing: Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: context.colorTextTertiary,
              ),
            ),
            onTap: () => _showAppInfo(context),
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: '데이터 초기화',
            color: AppColors.error,
            onTap: () => _showResetConfirm(context, ref),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const EditProfileSheet(),
    );
  }

  void _showGoalSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const GoalSettingsSheet(),
    );
  }

  void _showLanguageInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('현재 한국어만 지원됩니다 🇰🇷'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    final meals = ref.read(mealRecordsProvider);
    final weights = ref.read(weightRecordsProvider);
    final health = ref.read(dailyHealthProvider);

    // async 전에 context 의존 값 캡처
    final screenSize = MediaQuery.of(context).size;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'profile': profile.toJson(),
      'weight_records': weights.map((w) => w.toJson()).toList(),
      'meal_records': meals.map((m) => m.toJson()).toList(),
      'daily_health': health.toJson(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    try {
      // 임시 디렉토리에 JSON 파일 저장 후 공유
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/fitmate_data_$timestamp.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'FitMate 데이터 내보내기',
        text: 'FitMate 앱 데이터가 첨부되었습니다.',
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          screenSize.width,
          screenSize.height / 2,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('데이터 내보내기 실패: $e'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FitMate',
      applicationVersion: 'v1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icons/app_icon.png',
          width: 48,
          height: 48,
        ),
      ),
      children: [
        const Text(
          'AI 기반 스마트 다이어트 코치\n\n'
          '식단 관리, 체중 추적, AI 영양 상담을\n'
          '한 곳에서 관리하세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  void _showApiStatus(BuildContext context, WidgetRef ref) {
    final foodService = ref.read(foodApiServiceProvider);
    final status = foodService.getApiStatus();
    final aiService = ref.read(aiChatServiceProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cloud_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('API 연결 상태', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildApiStatusRow('📦 내장 DB (80+ 음식)', true),
            _buildApiStatusRow('🏛️ 식약처 식품영양정보', status['publicApi'] ?? false),
            _buildApiStatusRow('🤖 OpenAI GPT 분석', aiService.isConfigured),
            _buildApiStatusRow('📷 바코드 검색 (Open Food Facts)', true),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colorBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '💡 .env 파일에 API 키를 설정하면\n더 많은 음식 정보를 검색할 수 있어요.',
                style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: context.colorTextSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiStatusRow(String label, bool connected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: connected
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  connected ? Icons.check_circle : Icons.warning_amber_rounded,
                  size: 14,
                  color: connected ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  connected ? '연결됨' : '미설정',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: connected ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('데이터 초기화'),
          ],
        ),
        content: const Text(
          '모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말 초기화하시겠습니까?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final resetFn = ref.read(dataResetProvider);
              await resetFn();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('데이터가 초기화되었습니다'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? color;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.color,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading:
              Icon(icon, color: color ?? context.colorTextSecondary, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color ?? context.colorTextPrimary,
            ),
          ),
          trailing: trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorTextTertiary,
                size: 20,
              ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        if (showDivider) const Divider(height: 0, indent: 56),
      ],
    );
  }
}
