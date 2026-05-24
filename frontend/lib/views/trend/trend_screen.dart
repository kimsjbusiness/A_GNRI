import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/report_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 6, minute: 0);
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.goldAccent,
              onPrimary: AppTheme.darkBg,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.darkBg,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00"; // Format for backend time field (HH:MM:SS)
  }

  void _savePreferences(BuildContext context, ReportStateProvider state) async {
    final timeStr = _formatTimeOfDay(_selectedTime);
    final success = await state.updateNotificationTime(timeStr);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? '알림 수신 시간이 ${timeStr.substring(0, 5)}으로 안전하게 저장되었습니다.' 
              : '저장에 실패했습니다. 백엔드 연결 상태를 확인해 주세요.',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          backgroundColor: success ? AppTheme.darkCard : AppTheme.errorRed,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: success ? AppTheme.goldAccent : AppTheme.errorRed),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReportStateProvider>();
    final token = _firebaseService.fcmToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALARM SETTINGS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsHeader(),
            const SizedBox(height: 24),
            _buildTimePickerCard(context),
            const SizedBox(height: 24),
            _buildFCMTokenCard(token),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: state.isSavingTime ? null : () => _savePreferences(context, state),
                child: state.isSavingTime
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBg))
                  : const Text('설정 저장하기'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '일일 통합 리포트 푸시 알림',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '글로벌 거시 경제 리포트 수집이 완료되는 즉시 FCM 푸시 알림을 발송합니다. 원하시는 알림 시간을 설정하세요.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerCard(BuildContext context) {
    final formattedTime = "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '알림 수신 예약 시간',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                formattedTime,
                style: const TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          IconButton.filled(
            onPressed: () => _pickTime(context),
            icon: const Icon(Icons.access_time_filled, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: AppTheme.darkBg,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFCMTokenCard(String token) {
    final isMock = token.startsWith("MOCK");
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isMock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isMock ? AppTheme.goldAccent : Colors.green,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isMock ? 'FCM 디버그 모드 작동 중' : 'FCM 알림 토큰 활성화 완료',
                style: TextStyle(
                  color: isMock ? AppTheme.goldAccent : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '디바이스 토큰: $token',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
