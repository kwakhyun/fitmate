import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF2DD4A8);
  static const Color primaryLight = Color(0xFF6EEBCB);
  static const Color primaryDark = Color(0xFF0FA87E);
  static const Color primarySurface = Color(0xFFE8FBF5);

  // Secondary
  static const Color secondary = Color(0xFFFF7E67);
  static const Color secondaryLight = Color(0xFFFFAA96);
  static const Color secondaryDark = Color(0xFFE65A42);

  // Accent
  static const Color accent = Color(0xFF6C5CE7);
  static const Color accentLight = Color(0xFFA29BFE);

  // Neutral
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F8);
  static const Color border = Color(0xFFE8ECF2);
  static const Color divider = Color(0xFFF0F2F5);

  // Text
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Chart
  static const Color chartCarbs = Color(0xFF6C5CE7);
  static const Color chartProtein = Color(0xFF2DD4A8);
  static const Color chartFat = Color(0xFFFF7E67);
  static const Color chartWater = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF00D2FF)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFFFFB347)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2DD4A8), Color(0xFF6C5CE7)],
  );

  // Dark Mode
  static const Color darkPrimarySurface = Color(0xFF0D2E26);

  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D28);
  static const Color darkSurfaceVariant = Color(0xFF242736);
  static const Color darkBorder = Color(0xFF2E3142);
  static const Color darkDivider = Color(0xFF252838);

  static const Color darkTextPrimary = Color(0xFFE8EAF0);
  static const Color darkTextSecondary = Color(0xFF9CA3B4);
  static const Color darkTextTertiary = Color(0xFF6B7189);
}

extension AppColorsExtension on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get colorBackground =>
      _isDark ? AppColors.darkBackground : AppColors.background;
  Color get colorSurface => _isDark ? AppColors.darkSurface : AppColors.surface;
  Color get colorSurfaceVariant =>
      _isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
  Color get colorBorder => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get colorDivider => _isDark ? AppColors.darkDivider : AppColors.divider;
  Color get colorTextPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get colorTextSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get colorTextTertiary =>
      _isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
  Color get colorPrimarySurface =>
      _isDark ? AppColors.darkPrimarySurface : AppColors.primarySurface;
}
