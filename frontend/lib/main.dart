import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/report_provider.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    try {
      final token = await messaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('FCM token fetch failed: $e');
    }
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const App(),
    ),
  );
}