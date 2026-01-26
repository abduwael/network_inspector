import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../config/network_inspector_config.dart';
import '../models/network_log_model.dart';

/// Service to capture and manage network requests for debugging
class NetworkInspectorService extends GetxService {
  final RxList<NetworkLogModel> _logs = <NetworkLogModel>[].obs;
  final RxBool _isDialogOpen = false.obs;

  late NetworkInspectorConfig _config;

  List<NetworkLogModel> get logs => _logs;
  bool get isDialogOpen => _isDialogOpen.value;
  bool get isEnabled => _config.enabled;
  NetworkInspectorConfig get config => _config;

  set isDialogOpen(bool value) => _isDialogOpen.value = value;

  /// Initialize with configuration
  void initialize(NetworkInspectorConfig config) {
    _config = config;
    if (_config.enabled) {
      debugPrint('🌐 Network Inspector Initialized');
    }
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
  }

  /// Add a network log
  void addLog(NetworkLogModel log) {
    if (!_config.enabled) return;

    _logs.insert(0, log); // Add to beginning for newest first

    // Keep only the last maxLogs entries
    if (_logs.length > _config.maxLogs) {
      _logs.removeRange(_config.maxLogs, _logs.length);
    }

    debugPrint('🌐 Network Log: ${log.method} ${log.url} -> ${log.statusText}');
  }

  /// Log a request start
  String logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final log = NetworkLogModel(
      id: id,
      timestamp: DateTime.now(),
      method: method,
      url: url,
      headers: headers,
      requestBody: body,
    );

    addLog(log);
    return id;
  }

  /// Update a log with response data
  void updateLogWithResponse(
    String logId, {
    int? statusCode,
    dynamic responseBody,
    Duration? duration,
    String? error,
  }) {
    final index = _logs.indexWhere((log) => log.id == logId);
    if (index == -1) return;

    final existingLog = _logs[index];
    final updatedLog = existingLog.copyWith(
      statusCode: statusCode,
      responseBody: responseBody,
      duration: duration,
      error: error,
    );

    _logs[index] = updatedLog;
  }

  /// Get logs as JSON for export
  String exportLogsAsJson() {
    final logsData = _logs.map((log) => log.toJson()).toList();
    return jsonEncode(
        {'logs': logsData, 'exportedAt': DateTime.now().toIso8601String()});
  }

  /// Get summary statistics
  Map<String, dynamic> getStatistics() {
    final total = _logs.length;
    final errors = _logs.where((log) => log.error != null).length;
    final successes = _logs
        .where((log) =>
            log.statusCode != null &&
            log.statusCode! >= 200 &&
            log.statusCode! < 300)
        .length;
    final avgDuration = _logs.where((log) => log.duration != null).isNotEmpty
        ? _logs
                .where((log) => log.duration != null)
                .map((log) => log.duration!.inMilliseconds)
                .reduce((a, b) => a + b) /
            _logs.where((log) => log.duration != null).length
        : 0.0;

    return {
      'total': total,
      'errors': errors,
      'successes': successes,
      'averageDurationMs': avgDuration.round(),
    };
  }
}
