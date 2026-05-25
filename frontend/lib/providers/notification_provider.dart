import 'dart:async';

import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class AppNotificationItem {
  final String id;
  final DateTime createdAt;
  final String title;
  final String subtitle;
  final bool isRead;

  const AppNotificationItem({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.subtitle,
    required this.isRead,
  });

  AppNotificationItem copyWith({bool? isRead}) => AppNotificationItem(
        id: id,
        createdAt: createdAt,
        title: title,
        subtitle: subtitle,
        isRead: isRead ?? this.isRead,
      );
}

class NotificationProvider extends ChangeNotifier {
  bool _hasUnread = false;
  bool _showBanner = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  final List<AppNotificationItem> _items = [];
  StreamSubscription<DateTime>? _notificationSubscription;

  NotificationProvider() {
    for (final createdAt in NotificationService.takePendingNotificationEvents()) {
      addReportNotification(createdAt: createdAt, notify: false);
    }
    _notificationSubscription =
        NotificationService.notificationEvents.listen((createdAt) {
      addReportNotification(createdAt: createdAt);
    });
  }

  bool get hasUnread => _hasUnread;
  bool get showBanner => _showBanner;
  TimeOfDay get notificationTime => _notificationTime;
  List<AppNotificationItem> get items => List.unmodifiable(_items);

  void setNotificationTime(TimeOfDay time) {
    _notificationTime = time;
    notifyListeners();
  }

  void triggerNotification() {
    addReportNotification();
  }

  void dismissBanner() {
    _showBanner = false;
    notifyListeners();
  }

  void markAsRead() {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    _syncUnreadState();
    notifyListeners();
  }

  void markItemAsRead(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isRead: true);
    _syncUnreadState();
    notifyListeners();
  }

  void syncDueScheduledNotification() {
    final now = DateTime.now();
    final scheduledToday = DateTime(
      now.year,
      now.month,
      now.day,
      _notificationTime.hour,
      _notificationTime.minute,
    );
    if (now.isBefore(scheduledToday)) return;
    final alreadyExists = _items.any((item) =>
        item.createdAt.year == now.year &&
        item.createdAt.month == now.month &&
        item.createdAt.day == now.day);
    if (alreadyExists) return;
    addReportNotification(createdAt: now);
  }

  void addReportNotification({DateTime? createdAt, bool notify = true}) {
    final arrivedAt = createdAt ?? DateTime.now();
    _items.insert(
      0,
      AppNotificationItem(
        id: arrivedAt.microsecondsSinceEpoch.toString(),
        createdAt: arrivedAt,
        title: '오늘의 글로벌 리포트가 도착했습니다',
        subtitle: '지정한 시간의 리포트 알림이 도착했습니다.',
        isRead: false,
      ),
    );
    _hasUnread = true;
    _showBanner = true;
    if (notify) notifyListeners();
  }

  void _syncUnreadState() {
    _hasUnread = _items.any((item) => !item.isRead);
    if (!_hasUnread) {
      _showBanner = false;
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
