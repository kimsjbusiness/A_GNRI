import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

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
          // 알림 벨 (읽지 않은 알림 있을 때 빨간 점)
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/notifications');
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none),
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
          const Icon(Icons.dark_mode_outlined),
          const SizedBox(width: 8),
          const Icon(Icons.settings_outlined),
        ],
      ),
    );
  }
}
