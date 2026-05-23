import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    try {
      // Set up foreground message handler if Firebase is initialized
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log("Foreground message received: ${message.notification?.title}", name: "NotificationService");
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      developer.log("Notification listeners configured.", name: "NotificationService");
    } catch (e) {
      developer.log("NotificationService initialization skipped (Firebase not configured).", name: "NotificationService");
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    developer.log("Handling background message: ${message.messageId}", name: "NotificationService");
  }
}
