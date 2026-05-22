// 1면/2면/3면 전환을 위한 상단 탭 네비게이션 위젯

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../screens/home_screen.dart';
import '../screens/insight_screen.dart';
import '../screens/trend_screen.dart';

class PageTabBar extends StatelessWidget {
  final int selectedPage; // 1, 2, 3

  const PageTabBar({
    super.key,
    required this.selectedPage,
  });

  void _moveToPage(BuildContext context, int page) {
    if (page == selectedPage) return;

    switch (page) {
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) => const HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) => const InsightScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) => const TrendScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.tabBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              title: '1면',
              isSelected: selectedPage == 1,
              onTap: () => _moveToPage(context, 1),
            ),
          ),
          Expanded(
            child: _TabItem(
              title: '2면',
              isSelected: selectedPage == 2,
              onTap: () => _moveToPage(context, 2),
            ),
          ),
          Expanded(
            child: _TabItem(
              title: '3면',
              isSelected: selectedPage == 3,
              onTap: () => _moveToPage(context, 3),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected ? colors.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? colors.background : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
