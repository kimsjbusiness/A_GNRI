import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ReportProvider extends ChangeNotifier {
  DailyReport? _report;
  bool _isLoading = false;
  String? _error;

  List<ReportHistoryItem> _history = [];
  bool _isLoadingHistory = false;
  List<ReportKeyword> _realtimeTrends = [];
  bool _isLoadingTrends = false;

  bool _isPipelineRunning = false;
  int _pipelineProgress = 0;
  String _pipelineStatus = '';
  Timer? _pollTimer;

  DailyReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _report != null;

  List<ReportHistoryItem> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingTrends => _isLoadingTrends;

  bool get isPipelineRunning => _isPipelineRunning;
  int get pipelineProgress => _pipelineProgress;
  String get pipelineStatus => _pipelineStatus;
  bool get hasPipelineStatus =>
      _isPipelineRunning || _pipelineProgress > 0 || _pipelineStatus.isNotEmpty;

  Uint8List? imageAt(int index) {
    if (_report == null || index >= _report!.images.length) return null;
    try {
      return base64Decode(_report!.images[index].imageDataBase64);
    } catch (_) {
      return null;
    }
  }

  String get marketSentiment => _normalizeSentiment(_report?.marketSentiment);

  List<Map<String, String>> get trendKeywords {
    final keywords = _realtimeTrends.isNotEmpty
        ? _realtimeTrends
        : _report?.keywords ?? const <ReportKeyword>[];
    return keywords
            .map((k) => {'rank': k.ranking.toString(), 'keyword': k.keyword})
            .toList();
  }

  Map<String, dynamic> get insightData {
    final r = _report;
    if (r == null) return _defaultInsightData;
    final sentiment = _normalizeSentiment(r.marketSentiment);
    final positiveRatio =
        sentiment == '밝음' ? 0.72 : sentiment == '보통' ? 0.50 : 0.28;
    final themes = r.stockTheme
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return {
      'mood': sentiment,
      'confidence': '${(positiveRatio * 100).round()}%',
      'themes': themes.isEmpty ? [r.stockTheme] : themes,
      'keywords': r.keywords.map((k) => k.keyword).toList(),
      'summary':
          '현재 시장 분위기는 $sentiment이며, 주목 테마는 ${themes.join(', ')}입니다.',
      'reason': r.top3Sentences.join(' '),
      'positiveRatio': positiveRatio,
      'negativeRatio': 1.0 - positiveRatio,
    };
  }

  static const Map<String, dynamic> _defaultInsightData = {
    'mood': '밝음',
    'confidence': '72%',
    'themes': ['친환경 에너지', '반도체'],
    'keywords': ['기후', '탄소 감축', '경제 회복', '반도체'],
    'summary': '현재 시장 분위기는 밝으며, 주목 테마는 친환경 에너지와 반도체입니다.',
    'reason': '글로벌 탄소 감축 합의와 아시아 태평양 지역의 경기 회복 흐름이 반영되었습니다.',
    'positiveRatio': 0.72,
    'negativeRatio': 0.28,
  };

  static String _normalizeSentiment(String? value) {
    final normalized = value?.trim();
    if (normalized == '밝음' || normalized?.contains('諛') == true) return '밝음';
    if (normalized == '보통' || normalized?.contains('蹂') == true) return '보통';
    if (normalized == '어두움' || normalized?.contains('몢') == true) return '어두움';
    return '밝음';
  }

  Future<void> loadLatest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _report = await ApiService.getTodayReport();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByDate(String date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _report = await ApiService.getReportByDate(date);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      _history = await ApiService.getReportHistory();
    } catch (_) {
      // 히스토리 로딩 실패 시 빈 목록 유지
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadRealtimeTrends() async {
    _isLoadingTrends = true;
    notifyListeners();
    try {
      _realtimeTrends = await ApiService.getRealtimeTrends();
    } catch (_) {
      _realtimeTrends = [];
    } finally {
      _isLoadingTrends = false;
      notifyListeners();
    }
  }

  Future<void> syncPipelineStatus() async {
    try {
      final status = await ApiService.getPipelineStatus();
      _applyPipelineStatus(status);
      notifyListeners();
      if (_isPipelineRunning) {
        _startPolling();
      }
    } catch (_) {}
  }

  Future<void> triggerPipeline() async {
    if (_isPipelineRunning) return;

    _isPipelineRunning = true;
    _pipelineProgress = 5;
    _pipelineStatus = '최신화 작업을 시작하는 중입니다...';
    notifyListeners();

    try {
      await ApiService.triggerPipeline();
    } on DioException catch (e) {
      if (e.response?.statusCode != 409) {
        _isPipelineRunning = false;
        _pipelineProgress = 0;
        _pipelineStatus = '최신화 요청에 실패했습니다. 백엔드 서버를 확인해주세요.';
        notifyListeners();
        return;
      }
      // Backend already has a running pipeline. Continue by polling its status.
    } catch (_) {
      _isPipelineRunning = false;
      _pipelineProgress = 0;
      _pipelineStatus = '최신화 요청에 실패했습니다. 백엔드 서버를 확인해주세요.';
      notifyListeners();
      return;
    }

    await syncPipelineStatus();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final status = await ApiService.getPipelineStatus();
        _applyPipelineStatus(status);

        if (!_isPipelineRunning) {
          _pollTimer?.cancel();
          notifyListeners();
          if (_pipelineProgress == 100) {
            await loadLatest();
            await NotificationService.showReportReadyNotification();
          }
          return;
        }
        notifyListeners();
      } catch (_) {}
    });
  }

  void _applyPipelineStatus(Map<String, dynamic> status) {
    _isPipelineRunning = (status['is_running'] as bool?) ?? false;
    _pipelineProgress =
        ((status['progress'] as num?) ?? 0).round().clamp(0, 100);
    _pipelineStatus = (status['status'] as String?) ?? '';
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
