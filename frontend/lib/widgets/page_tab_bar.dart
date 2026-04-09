/// 1면/2면/3면 전환을 위한 상단 탭 네비게이션 위젯
/// 리포트(1면/2면/3면) 화면 간 이동을 위한 공통 상단 탭 위젯

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/insight_screen.dart';

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
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const InsightScreen(),
          ),
        );
        break;
      case 3:
        // 아직 미구현
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9ED),
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
          const Expanded(
            child: _TabItem(
              title: '3면',
              isSelected: false,
              isDisabled: true,
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
  final bool isDisabled;

  const _TabItem({
    required this.title,
    required this.isSelected,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDisabled
                    ? const Color(0xFFB5B5BD)
                    : const Color(0xFF222222),
              ),
            ),
          ),
        ),
      ),
    );
  }
}