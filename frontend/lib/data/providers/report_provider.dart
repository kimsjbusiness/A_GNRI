import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class ReportProvider {
  final Dio _dio;

  ReportProvider()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log("API REQUEST [${options.method}] -> ${options.path}", name: "ReportProvider");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log("API RESPONSE [${response.statusCode}] <- ${response.requestOptions.path}", name: "ReportProvider");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        developer.log("API ERROR [${e.response?.statusCode}] <- ${e.requestOptions.path}: ${e.message}", name: "ReportProvider", error: e);
        return handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> fetchTodayReport() async {
    try {
      final response = await _dio.get('/reports/today');
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      throw Exception("Invalid response format for today's report.");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchPastReport(String dateStr) async {
    try {
      final response = await _dio.get('/reports/$dateStr');
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      throw Exception("Invalid response format for past report.");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveNotificationTime(String token, String timeStr) async {
    try {
      // timeStr should be in the format 'HH:MM:SS'
      final response = await _dio.post(
        '/users',
        data: {
          'device_token': token,
          'notification_time': timeStr,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      throw Exception("Invalid response format for saving user preferences.");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> triggerPipeline() async {
    try {
      final response = await _dio.post('/test-trigger-pipeline');
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      throw Exception("Invalid response format for triggering pipeline.");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchPipelineStatus() async {
    try {
      final response = await _dio.get('/reports/today/pipeline-status');
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      throw Exception("Invalid response format for pipeline status.");
    } catch (e) {
      rethrow;
    }
  }
}
