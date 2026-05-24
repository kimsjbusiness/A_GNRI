import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  bool _hasUnread = false;
  bool _showBanner = false;

  bool get hasUnread => _hasUnread;
  bool get showBanner => _showBanner;

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
