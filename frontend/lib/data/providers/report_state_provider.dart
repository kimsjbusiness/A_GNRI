import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/report_model.dart';
import '../repositories/report_repository.dart';
import '../../services/firebase_service.dart';

class ReportStateProvider extends ChangeNotifier {
  final ReportRepository _repository;
  final FirebaseService _firebaseService = FirebaseService();

  DailyReportModel? _todayReport;
  DailyReportModel? _searchedReport;
  bool _isLoading = false;
  String? _errorMessage;
  String _notificationTime = "06:00:00";
  bool _isSavingTime = false;
  bool _isTriggering = false;
  int _pipelineProgress = 0;
  String _pipelineStatusMessage = "";
  Timer? _statusTimer;
  bool _hasJustFinishedPipeline = false;

  DailyReportModel? get todayReport => _todayReport;
  DailyReportModel? get searchedReport => _searchedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get notificationTime => _notificationTime;
  bool get isSavingTime => _isSavingTime;
  bool get isTriggering => _isTriggering;
  int get pipelineProgress => _pipelineProgress;
  String get pipelineStatusMessage => _pipelineStatusMessage;
  bool get hasJustFinishedPipeline => _hasJustFinishedPipeline;

  ReportStateProvider({ReportRepository? repository}) : _repository = repository ?? ReportRepository();

  Future<void> fetchTodayReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayReport = await _repository.getTodayReport();
      _errorMessage = null;
    } catch (e) {
      developer.log("Failed to fetch today report in StateProvider", error: e);
      _errorMessage = "오늘의 리포트를 가져오지 못했습니다.\n백엔드 서버와 데이터베이스가 정상 구동 중인지 확인해 주세요.";
      _todayReport = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPastReport(String dateStr) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchedReport = await _repository.getPastReport(dateStr);
      _errorMessage = null;
    } catch (e) {
      developer.log("Failed to fetch past report for $dateStr in StateProvider", error: e);
      _errorMessage = "$dateStr 날짜의 리포트를 찾을 수 없습니다.";
      _searchedReport = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchedReport() {
    _searchedReport = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateNotificationTime(String newTimeStr) async {
    _isSavingTime = true;
    notifyListeners();

    try {
      final token = _firebaseService.fcmToken;
      await _repository.saveUserPreferences(token, newTimeStr);
      _notificationTime = newTimeStr;
      _isSavingTime = false;
      notifyListeners();
      return true;
    } catch (e) {
      developer.log("Failed to save notification time", error: e);
      _isSavingTime = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> triggerTodayPipeline() async {
    _isTriggering = true;
    _pipelineProgress = 0;
    _pipelineStatusMessage = "최신화 가동 요청 중...";
    notifyListeners();

    try {
      await _repository.triggerTodayPipeline();
      _startStatusPolling();
      return true;
    } catch (e) {
      developer.log("Failed to trigger pipeline in StateProvider", error: e);
      _isTriggering = false;
      _pipelineProgress = 0;
      _pipelineStatusMessage = "";
      notifyListeners();
      return false;
    }
  }

  void clearFinishedPipelineFlag() {
    _hasJustFinishedPipeline = false;
    notifyListeners();
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      try {
        final statusMap = await _repository.fetchPipelineStatus();
        final isRunning = statusMap['is_running'] as bool? ?? false;
        final progress = statusMap['progress'] as int? ?? 0;
        final statusStr = statusMap['status'] as String? ?? "";

        _pipelineProgress = progress;
        _pipelineStatusMessage = statusStr;

        if (!isRunning || progress >= 100) {
          timer.cancel();
          _isTriggering = false;
          if (progress >= 100) {
            _hasJustFinishedPipeline = true;
            await fetchTodayReport();
          }
          _pipelineProgress = 0;
          _pipelineStatusMessage = "";
        }
        notifyListeners();
      } catch (e) {
        developer.log("Error in pipeline status polling: $e", name: "ReportStateProvider");
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
