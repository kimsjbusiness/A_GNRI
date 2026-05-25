import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TimeOfDay _selectedTime;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _timeExpanded = false;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;

  @override
  void initState() {
    super.initState();
    _selectedTime = context.read<NotificationProvider>().notificationTime;
    _hourCtrl = FixedExtentScrollController(initialItem: _selectedTime.hour);
    _minCtrl = FixedExtentScrollController(initialItem: _selectedTime.minute);
    _initNotification();
  }

  Future<void> _initNotification() async {
    await NotificationService.requestPermission();
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
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Divider(height: 1, thickness: 1, color: colors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '알림 및 시스템 설정을 관리합니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 알림 설정 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 18,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '알림 설정',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 알림 시간 행
                          GestureDetector(
                            onTap: () {
                              final expanding = !_timeExpanded;
                              setState(() => _timeExpanded = expanding);
                              if (expanding) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _hourCtrl.jumpToItem(_selectedTime.hour);
                                  _minCtrl.jumpToItem(_selectedTime.minute);
                                });
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '알림 시간',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _formatTime(_selectedTime),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
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
                                        color: colors.textSecondary,
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
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 140,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 64,
                                                    height: 140,
                                                    child: ListWheelScrollView
                                                        .useDelegate(
                                                      controller: _hourCtrl,
                                                      itemExtent: 44,
                                                      perspective: 0.003,
                                                      physics: const FixedExtentScrollPhysics(),
                                                      onSelectedItemChanged:
                                                          (v) => setState(() {
                                                        _selectedTime =
                                                            TimeOfDay(
                                                          hour: v,
                                                          minute: _selectedTime
                                                              .minute,
                                                        );
                                                      }),
                                                      childDelegate:
                                                          ListWheelChildBuilderDelegate(
                                                        childCount: 24,
                                                        builder: (_, i) =>
                                                            Center(
                                                          child: Text(
                                                            i
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0'),
                                                            style: TextStyle(
                                                              fontSize: 26,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: colors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 140,
                                                    child: Center(
                                                      child: Text(
                                                        ':',
                                                        style: TextStyle(
                                                          fontSize: 26,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: colors
                                                              .textPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 64,
                                                    height: 140,
                                                    child: ListWheelScrollView
                                                        .useDelegate(
                                                      controller: _minCtrl,
                                                      itemExtent: 44,
                                                      perspective: 0.003,
                                                      physics: const FixedExtentScrollPhysics(),
                                                      onSelectedItemChanged:
                                                          (v) => setState(() {
                                                        _selectedTime =
                                                            TimeOfDay(
                                                          hour:
                                                              _selectedTime.hour,
                                                          minute: v,
                                                        );
                                                      }),
                                                      childDelegate:
                                                          ListWheelChildBuilderDelegate(
                                                        childCount: 60,
                                                        builder: (_, i) =>
                                                            Center(
                                                          child: Text(
                                                            i
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0'),
                                                            style: TextStyle(
                                                              fontSize: 26,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: colors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // 선택된 항목 중앙 표시선
                                              IgnorePointer(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 44,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12),
                                                      decoration: BoxDecoration(
                                                        border: Border.symmetric(
                                                          horizontal:
                                                              BorderSide(
                                                            color: colors
                                                                .textSecondary
                                                                .withValues(
                                                                    alpha:
                                                                        0.35),
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              setState(
                                                  () => _timeExpanded = false);
                                              context.read<NotificationProvider>().setNotificationTime(_selectedTime);
                                              await NotificationService
                                                  .scheduleDailyNotification(
                                                      _selectedTime);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '알림 시간이 ${_formatTime(_selectedTime)}로 설정되었습니다',
                                                    ),
                                                    duration: const Duration(
                                                        seconds: 2),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin: const EdgeInsets.only(
                                                      bottom: 80,
                                                      left: 16,
                                                      right: 16,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  colors.textPrimary,
                                              foregroundColor:
                                                  colors.background,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              '저장',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                  Text(
                                    '알림음',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '알림 발생 시 소리 재생',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _soundEnabled,
                                onChanged: (v) =>
                                    setState(() => _soundEnabled = v),
                                activeThumbColor: colors.textPrimary,
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
                                  Text(
                                    '진동',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '알림 발생 시 진동 (모바일)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _vibrationEnabled,
                                onChanged: (v) =>
                                    setState(() => _vibrationEnabled = v),
                                activeThumbColor: colors.textPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 알림 테스트 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                context
                                    .read<NotificationProvider>()
                                    .triggerNotification();
                                await NotificationService.showTestNotification();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.textPrimary,
                                foregroundColor: colors.background,
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
