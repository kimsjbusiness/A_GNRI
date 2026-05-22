import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import '../core/theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.header,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF050A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🌎')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global News Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '전세계 통합 뉴스 & 경제 리포트',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/notifications'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none, color: colors.textPrimary),
                  if (provider.hasUnread)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => GestureDetector(
              onTap: themeProvider.toggle,
              child: Icon(
                themeProvider.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
            child: Icon(Icons.settings_outlined, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
