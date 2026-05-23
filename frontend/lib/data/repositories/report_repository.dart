import 'dart:developer' as developer;
import '../models/report_model.dart';
import '../providers/report_provider.dart';

class ReportRepository {
  final ReportProvider _provider;

  ReportRepository({ReportProvider? provider}) : _provider = provider ?? ReportProvider();

  Future<DailyReportModel> getTodayReport() async {
    try {
      final json = await _provider.fetchTodayReport();
      return DailyReportModel.fromJson(json);
    } catch (e) {
      developer.log("Error in repository getTodayReport", error: e);
      rethrow;
    }
  }

  Future<DailyReportModel> getPastReport(String dateStr) async {
    try {
      final json = await _provider.fetchPastReport(dateStr);
      return DailyReportModel.fromJson(json);
    } catch (e) {
      developer.log("Error in repository getPastReport for date: $dateStr", error: e);
      rethrow;
    }
  }

  Future<void> saveUserPreferences(String deviceToken, String notificationTimeStr) async {
    try {
      await _provider.saveNotificationTime(deviceToken, notificationTimeStr);
    } catch (e) {
      developer.log("Error in repository saveUserPreferences", error: e);
      rethrow;
    }
  }

  Future<void> triggerTodayPipeline() async {
    try {
      await _provider.triggerPipeline();
    } catch (e) {
      developer.log("Error in repository triggerTodayPipeline", error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchPipelineStatus() async {
    try {
      return await _provider.fetchPipelineStatus();
    } catch (e) {
      developer.log("Error in repository fetchPipelineStatus", error: e);
      rethrow;
    }
  }
}
