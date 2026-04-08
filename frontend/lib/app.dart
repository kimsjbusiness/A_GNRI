import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global News Report',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        fontFamily: 'Pretendard', // 없으면 자동 기본 폰트 사용
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B1020)),
      ),
      home: const HomeScreen(),
    );
  }
}