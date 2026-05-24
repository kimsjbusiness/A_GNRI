import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  DailyReport? _report;
  bool _isLoading = false;
  String? _error;

  List<ReportHistoryItem> _history = [];
  bool _isLoadingHistory = false;

  DailyReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _report != null;

  List<ReportHistoryItem> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;

  Uint8List? imageAt(int index) {
    if (_report == null || index >= _report!.images.length) return null;
    try {
      return base64Decode(_report!.images[index].imageDataBase64);
    } catch (_) {
      return null;
    }
  }

  String get marketSentiment => _report?.marketSentiment ?? '밝음';

  List<Map<String, String>> get trendKeywords {
    return _report?.keywords
            .map((k) => {'rank': k.ranking.toString(), 'keyword': k.keyword})
            .toList() ??
        [];
  }

  Map<String, dynamic> get insightData {
    final r = _report;
    if (r == null) return _defaultInsightData;
    final sentiment = r.marketSentiment;
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
          '현재 시장의 분위기는 $sentiment이며, 주목할 테마는 ${themes.join(', ')}입니다.',
      'reason': r.top3Sentences.join(' '),
      'positiveRatio': positiveRatio,
      'negativeRatio': 1.0 - positiveRatio,
    };
  }

  static const Map<String, dynamic> _defaultInsightData = {
    'mood': '밝음',
    'confidence': '72%',
    'themes': ['친환경 에너지', '반도체'],
    'keywords': ['기후', '탄소감축', '경제회복', '반도체'],
    'summary': '현재 시장의 분위기는 밝으며, 주목할 테마는 친환경 에너지, 반도체입니다.',
    'reason': '글로벌 기후 정상회의의 탄소 감축 합의와 아시아 태평양 지역의 경기 회복이 반영되었습니다.',
    'positiveRatio': 0.72,
    'negativeRatio': 0.28,
  };

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
}
