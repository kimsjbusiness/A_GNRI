import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

const _channelId = 'daily_report';
const _channelName = '일일 리포트';
const _scheduledId = 0;
const _testId = 1;

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );
  }

  static void _onTap(NotificationResponse response) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundTap(NotificationResponse response) {}

  static Future<bool> requestPermission() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await impl?.requestNotificationsPermission() ?? false;
  }

  static Future<void> scheduleDailyNotification(TimeOfDay time) async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.cancel(_scheduledId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await android.zonedSchedule(
      _scheduledId,
      'Global News Report',
      '오늘의 글로벌 리포트가 도착했습니다\n시장 분위기: 밝음 · 테마: 친환경 & AI 기술',
      scheduled,
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: '매일 뉴스 리포트 알림',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
      ),
      scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showTestNotification() async {
    await _plugin.show(
      _testId,
      'Global News Report',
      '오늘의 글로벌 리포트가 도착했습니다\n시장 분위기: 밝음 · 테마: 친환경 & AI 기술',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }
}
