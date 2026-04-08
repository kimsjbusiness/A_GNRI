import 'package:flutter/material.dart';

/// 모든 탭에서 공유하는 상단 헤더 위젯
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global News Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  '전세계 통합 뉴스 & 경제 리포트',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_none),
          const SizedBox(width: 8),
          const Icon(Icons.dark_mode_outlined),
          const SizedBox(width: 8),
          const Icon(Icons.settings_outlined),
        ],
      ),
    );
  }
}
