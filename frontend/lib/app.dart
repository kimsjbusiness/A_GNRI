import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'widgets/in_app_banner.dart';
import 'providers/theme_provider.dart';
import 'core/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Global News Report',
          navigatorKey: NotificationService.navigatorKey,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.mode,
          initialRoute: '/splash',
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/splash':
                page = const SplashScreen();
                break;
              case '/archive':
                page = const ArchiveScreen();
                break;
              case '/settings':
                page = const SettingsScreen();
                break;
              case '/notifications':
                page = const NotificationScreen();
                break;
              default:
                page = const HomeScreen();
            }
            return PageRouteBuilder(
              pageBuilder: (context, a1, a2) => page,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              settings: settings,
            );
          },
          builder: (context, child) =>
              InAppBannerOverlay(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
