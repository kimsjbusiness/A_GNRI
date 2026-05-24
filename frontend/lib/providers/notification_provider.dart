import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool _hasUnread = false;
  bool _showBanner = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  bool get hasUnread => _hasUnread;
  bool get showBanner => _showBanner;
  TimeOfDay get notificationTime => _notificationTime;

  void setNotificationTime(TimeOfDay time) {
    _notificationTime = time;
    notifyListeners();
  }

  void triggerNotification() {
    _hasUnread = true;
    _showBanner = true;
    notifyListeners();
  }

  void dismissBanner() {
    _showBanner = false;
    notifyListeners();
  }

  void markAsRead() {
    _hasUnread = false;
    notifyListeners();
  }
}
