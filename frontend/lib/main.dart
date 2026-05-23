import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/report_state_provider.dart';
import 'core/theme/app_theme.dart';
import 'views/main_layout.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail-safe Firebase & Notification Services initialization
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportStateProvider()),
      ],
      child: MaterialApp(
        title: 'Global News Integrator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainLayout(),
      ),
    );
  }
}
