import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotifItem> _items = [
    _NotifItem(
      date: '오늘 09:00',
      title: '오늘의 글로벌 리포트가 도착했습니다',
      subtitle: '시장 분위기: 밝음 · 테마: 친환경 & AI 기술',
      isRead: false,
    ),
    _NotifItem(
      date: '2026년 4월 1일 09:00',
      title: '어제의 글로벌 리포트가 도착했습니다',
      subtitle: '시장 분위기: 어두움 · 테마: 방위주 & 에너지',
      isRead: true,
    ),
    _NotifItem(
      date: '2026년 3월 31일 09:00',
      title: '글로벌 리포트가 도착했습니다',
      subtitle: '시장 분위기: 보통 · 테마: 핀테크 & 물류',
      isRead: true,
    ),
    _NotifItem(
      date: '2026년 3월 30일 09:00',
      title: '글로벌 리포트가 도착했습니다',
      subtitle: '시장 분위기: 밝음 · 테마: 반도체 & 바이오',
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 배지 제거
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAsRead();
    });
  }

  void _onTapItem(int index) {
    setState(() => _items[index] = _items[index].copyWith(isRead: true));
    Navigator.pushReplacementNamed(context, '/');
  }

  void _markAllRead() {
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _items.any((n) => !n.isRead);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE3E3E8)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '알림',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (hasUnread)
                          GestureDetector(
                            onTap: _markAllRead,
                            child: Text(
                              '모두 읽음',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '리포트 알림 내역을 확인하세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 20),
                    if (_items.isEmpty)
                      const _EmptyState()
                    else
                      ...List.generate(_items.length, (i) {
                        final item = _items[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NotifCard(
                            item: item,
                            onTap: () => _onTapItem(i),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: -1),
          ],
        ),
      ),
    );
  }
}

// ─── 알림 아이템 모델 ──────────────────────────────────────────────────────────
class _NotifItem {
  final String date;
  final String title;
  final String subtitle;
  final bool isRead;

  const _NotifItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.isRead,
  });

  _NotifItem copyWith({bool? isRead}) => _NotifItem(
        date: date,
        title: title,
        subtitle: subtitle,
        isRead: isRead ?? this.isRead,
      );
}

// ─── 알림 카드 ─────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  final VoidCallback onTap;

  const _NotifCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? Colors.grey.shade200
                : const Color(0xFFD0DCFF),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF050A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🌎', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Global News Report',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          item.isRead ? FontWeight.w500 : FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 10),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4B6EF5),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── 빈 상태 ───────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.notifications_none, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              '알림이 없습니다',
              style: TextStyle(fontSize: 15, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
