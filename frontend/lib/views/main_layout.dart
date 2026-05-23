import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/report_state_provider.dart';
import '../core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'insight/insight_screen.dart';
import 'archive/archive_screen.dart';
import 'trend/trend_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const InsightScreen(),
    const ArchiveScreen(),
    const TrendScreen(), // Settings screen
  ];

  @override
  void initState() {
    super.initState();
    // Fetch today's report on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportStateProvider>().fetchTodayReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.darkBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.summarize_outlined),
              activeIcon: Icon(Icons.summarize),
              label: '일일 요약',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: '트렌드 & 분석',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined),
              activeIcon: Icon(Icons.archive),
              label: '아카이브',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '알림 설정',
            ),
          ],
        ),
      ),
    );
  }
}
