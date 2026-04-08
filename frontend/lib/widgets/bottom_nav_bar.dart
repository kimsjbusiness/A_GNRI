import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE3E3E8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.description_outlined,
            label: '리포트',
            selected: currentIndex == 0,
          ),
          _NavItem(
            icon: Icons.history,
            label: '기록',
            selected: currentIndex == 1,
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: '설정',
            selected: currentIndex == 2,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? const Color(0xFF111111) : const Color(0xFF8A8A95);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}