import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'daily_report_v2';
const _channelName = '일일 리포트';
const _channelDescription = '매일 글로벌 뉴스 리포트 알림';
const _scheduledId = 0;
const _testId = 1;
const _reportReadyId = 2;
const _scheduledArrivedId = 3;

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static final _notificationEvents = StreamController<DateTime>.broadcast();
  static final List<DateTime> _pendingNotificationEvents = [];

  static Stream<DateTime> get notificationEvents => _notificationEvents.stream;

  static List<DateTime> takePendingNotificationEvents() {
    final events = List<DateTime>.from(_pendingNotificationEvents);
    _pendingNotificationEvents.clear();
    return events;
  }

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    await _syncTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _recordNotificationEvent(DateTime.now());
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    try {
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
    } catch (_) {}
  }

  static Future<void> _syncTimezone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }
  }

  static void _onTap(NotificationResponse response) {
    _recordNotificationEvent(DateTime.now());
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/notifications', (_) => false);
  }

  static void _recordNotificationEvent(DateTime createdAt) {
    if (_notificationEvents.hasListener) {
      _notificationEvents.add(createdAt);
    } else {
      _pendingNotificationEvents.add(createdAt);
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundTap(NotificationResponse response) {}

  static Future<bool> requestPermission() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notificationGranted =
        await impl?.requestNotificationsPermission() ?? true;
    try {
      await impl?.requestExactAlarmsPermission();
    } catch (_) {}
    return notificationGranted;
  }

  static Future<void> scheduleDailyNotification(TimeOfDay time) async {
    await _syncTimezone();
    await requestPermission();
    await _plugin.cancel(_scheduledId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _scheduleNotification(
        scheduled,
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _scheduleNotification(
        scheduled,
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> _scheduleNotification(
    tz.TZDateTime scheduled,
    AndroidScheduleMode scheduleMode,
  ) {
    return _plugin.zonedSchedule(
      _scheduledId,
      '글로벌 뉴스 리포트',
      '지정한 시간의 리포트 알림이 도착했습니다.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showReportReadyNotification() async {
    await _plugin.show(
      _reportReadyId,
      'A_GNRI 리포트 완료',
      '최신 글로벌 뉴스 리포트가 업데이트되었습니다.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  static Future<void> showScheduledNotification() async {
    await _plugin.show(
      _scheduledArrivedId,
      '글로벌 뉴스 리포트',
      '지정한 시간의 리포트 알림이 도착했습니다.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
    _recordNotificationEvent(DateTime.now());
  }

  static Future<void> showTestNotification() async {
    await _plugin.show(
      _testId,
      '글로벌 뉴스 리포트',
      '테스트 알림입니다.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }
}
