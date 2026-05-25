import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../core/theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().syncDueScheduledNotification();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return '오늘 $time';
    return '${date.year}년 ${date.month}월 ${date.day}일 $time';
  }

  void _onTapItem(AppNotificationItem item) {
    context.read<NotificationProvider>().markItemAsRead(item.id);
    Navigator.pushReplacementNamed(context, '/');
  }

  void _markAllRead() {
    context.read<NotificationProvider>().markAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;
    final hasUnread = provider.hasUnread;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Divider(height: 1, thickness: 1, color: colors.border),
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
                        Text(
                          '알림',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (hasUnread)
                          GestureDetector(
                            onTap: _markAllRead,
                            child: Text(
                              '모두 읽음',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '리포트 알림 내역을 확인하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (items.isEmpty)
                      const _EmptyState()
                    else
                      ...List.generate(items.length, (i) {
                        final item = items[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NotifCard(
                            item: item,
                            dateText: _formatDate(item.createdAt),
                            onTap: () => _onTapItem(item),
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

// ─── 알림 카드 ─────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final AppNotificationItem item;
  final String dateText;
  final VoidCallback onTap;

  const _NotifCard({
    required this.item,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    final unreadBg = isDark ? const Color(0xFF1A2348) : const Color(0xFFF0F4FF);
    final unreadBorder =
        isDark ? const Color(0xFF2A3560) : const Color(0xFFD0DCFF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? colors.surface : unreadBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead ? colors.border : unreadBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
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
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
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
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.notifications_none, size: 48, color: colors.border),
            const SizedBox(height: 12),
            Text(
              '알림이 없습니다',
              style: TextStyle(fontSize: 15, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
