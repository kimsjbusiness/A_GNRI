import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color header;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color tabBg;
  final Color chipBg;
  final Color iconBg;
  final Color wordCloudBg;

  const AppColors._({
    required this.background,
    required this.surface,
    required this.header,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.tabBg,
    required this.chipBg,
    required this.iconBg,
    required this.wordCloudBg,
  });

  static const light = AppColors._(
    background: Color(0xFFF6F6F8),
    surface: Colors.white,
    header: Colors.white,
    border: Color(0xFFE3E3E8),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF9A9AA5),
    tabBg: Color(0xFFE9E9ED),
    chipBg: Color(0xFFF1F1F5),
    iconBg: Color(0xFFF1F1F5),
    wordCloudBg: Color(0xFFF7F7FA),
  );

  static const dark = AppColors._(
    background: Color(0xFF0C0C0E),
    surface: Color(0xFF1A1A1F),
    header: Color(0xFF14141A),
    border: Color(0xFF2A2A32),
    textPrimary: Color(0xFFF0F0F2),
    textSecondary: Color(0xFF6A6A75),
    tabBg: Color(0xFF242430),
    chipBg: Color(0xFF252530),
    iconBg: Color(0xFF252530),
    wordCloudBg: Color(0xFF1E1E24),
  );
}

extension AppThemeX on BuildContext {
  AppColors get colors =>
      Theme.of(this).brightness == Brightness.dark
          ? AppColors.dark
          : AppColors.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B1020),
          brightness: Brightness.light,
        ),
        dividerColor: AppColors.light.border,
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B1020),
          brightness: Brightness.dark,
        ),
        dividerColor: AppColors.dark.border,
      );
}
