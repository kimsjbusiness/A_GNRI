import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _timeExpanded = false;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;

  @override
  void initState() {
    super.initState();
    _hourCtrl = FixedExtentScrollController(initialItem: _selectedTime.hour);
    _minCtrl = FixedExtentScrollController(initialItem: _selectedTime.minute);
    _initNotification();
  }

  Future<void> _initNotification() async {
    final granted = await NotificationService.requestPermission();
    if (granted) {
      await NotificationService.scheduleDailyNotification(_selectedTime);
    }
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE3E3E8)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '알림 및 시스템 설정을 관리합니다',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // 알림 설정 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 카드 헤더
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 18,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '알림 설정',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 알림 시간 행 (탭 시 인라인 휠 펼침)
                          GestureDetector(
                            onTap: () {
                              final wasExpanded = _timeExpanded;
                              setState(() => _timeExpanded = !_timeExpanded);
                              if (wasExpanded) {
                                NotificationService.scheduleDailyNotification(
                                    _selectedTime);
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '알림 시간',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _formatTime(_selectedTime),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedRotation(
                                      turns: _timeExpanded ? 0.25 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 인라인 스크롤 휠
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: _timeExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: SizedBox(
                                      height: 140,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // 시
                                          SizedBox(
                                            width: 64,
                                            child: ListWheelScrollView
                                                .useDelegate(
                                              controller: _hourCtrl,
                                              itemExtent: 44,
                                              perspective: 0.003,
                                              onSelectedItemChanged: (v) =>
                                                  setState(() {
                                                _selectedTime = TimeOfDay(
                                                  hour: v,
                                                  minute: _selectedTime.minute,
                                                );
                                              }),
                                              childDelegate:
                                                  ListWheelChildBuilderDelegate(
                                                childCount: 24,
                                                builder: (_, i) => Center(
                                                  child: Text(
                                                    i.toString().padLeft(2, '0'),
                                                    style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(bottom: 2),
                                            child: Text(
                                              ':',
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          // 분
                                          SizedBox(
                                            width: 64,
                                            child: ListWheelScrollView
                                                .useDelegate(
                                              controller: _minCtrl,
                                              itemExtent: 44,
                                              perspective: 0.003,
                                              onSelectedItemChanged: (v) =>
                                                  setState(() {
                                                _selectedTime = TimeOfDay(
                                                  hour: _selectedTime.hour,
                                                  minute: v,
                                                );
                                              }),
                                              childDelegate:
                                                  ListWheelChildBuilderDelegate(
                                                childCount: 60,
                                                builder: (_, i) => Center(
                                                  child: Text(
                                                    i.toString().padLeft(2, '0'),
                                                    style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 20),

                          // 알림음 토글
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '알림음',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '알림 발생 시 소리 재생',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _soundEnabled,
                                onChanged: (v) =>
                                    setState(() => _soundEnabled = v),
                                activeThumbColor: Colors.black,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 진동 토글
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '진동',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '알림 발생 시 진동 (모바일)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _vibrationEnabled,
                                onChanged: (v) =>
                                    setState(() => _vibrationEnabled = v),
                                activeThumbColor: Colors.black,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 알림 테스트 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // 인앱 배너 표시
                                context
                                    .read<NotificationProvider>()
                                    .triggerNotification();
                                // OS 알림도 발송 (앱이 백그라운드일 때 보임)
                                await NotificationService.showTestNotification();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '알림 테스트',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}
