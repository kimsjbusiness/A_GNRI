import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../models/report_model.dart';

class ApiService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static Future<DailyReport> getTodayReport() async {
    final res = await _dio.get('/reports/today');
    return DailyReport.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<DailyReport> getReportByDate(String date) async {
    final res = await _dio.get('/reports/$date');
    return DailyReport.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<List<ReportHistoryItem>> getReportHistory() async {
    final res = await _dio.get('/reports');
    return (res.data as List)
        .map((e) => ReportHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> triggerPipeline() async {
    await _dio.post('/test-trigger-pipeline');
  }

  static Future<Map<String, dynamic>> getPipelineStatus() async {
    final res = await _dio.get('/reports/today/pipeline-status');
    return res.data as Map<String, dynamic>;
  }

  static Future<List<ReportKeyword>> getRealtimeTrends() async {
    final res = await _dio.get('/reports/trends/realtime');
    return (res.data as List)
        .map((e) => ReportKeyword.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> registerUser(
    String deviceToken,
    String notificationTime,
  ) async {
    await _dio.post(
      '/users',
      data: {
        'device_token': deviceToken,
        'notification_time': notificationTime,
      },
    );
  }
}
