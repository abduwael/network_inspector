import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../models/network_log_model.dart';
import '../services/network_inspector_service.dart';

/// Helper class containing utility methods for Network Inspector
class NetworkInspectorHelpers {
  NetworkInspectorHelpers._();

  /// Get status color based on log state
  static Color getStatusColor(NetworkLogModel log) {
    if (log.error != null) return const Color(0xFFF44336);
    if (log.statusCode == null) return const Color(0xFF9E9E9E);
    if (log.statusCode! >= 200 && log.statusCode! < 300) {
      return const Color(0xFF4CAF50);
    }
    if (log.statusCode! >= 400 && log.statusCode! < 500) {
      return const Color(0xFFFF9800);
    }
    if (log.statusCode! >= 500) return const Color(0xFFF44336);
    return const Color(0xFF9E9E9E);
  }

  /// Get status icon based on log state
  static IconData getStatusIcon(NetworkLogModel log) {
    if (log.error != null) return Icons.error_outline;
    if (log.statusCode == null) return Icons.hourglass_empty;
    if (log.statusCode! >= 200 && log.statusCode! < 300) {
      return Icons.check_circle_outline;
    }
    if (log.statusCode! >= 400 && log.statusCode! < 500) {
      return Icons.warning_amber_outlined;
    }
    if (log.statusCode! >= 500) return Icons.dangerous_outlined;
    return Icons.help_outline;
  }

  /// Get duration color based on response time
  static Color getDurationColor(int ms) {
    if (ms < 300) return const Color(0xFF4CAF50);
    if (ms < 1000) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  /// Extract endpoint name from full URL
  static String getEndpointName(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.isEmpty || path == '/') return url;
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) return url;
      if (segments.length >= 2) {
        return '/${segments[segments.length - 2]}/${segments.last}';
      }
      return '/${segments.last}';
    } catch (e) {
      return url;
    }
  }

  /// Format JSON data for display
  static String formatJson(dynamic data) {
    try {
      if (data is String) {
        final parsed = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(parsed);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Copy text to clipboard with feedback
  static void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      'Content copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12,
    );
  }

  /// Export logs as JSON via share
  static void exportLogs(NetworkInspectorService? networkInspector) {
    if (networkInspector == null) return;
    final jsonData = networkInspector.exportLogsAsJson();

    Share.share(
      jsonData,
      subject: 'Network Inspector Logs - ${DateTime.now().toIso8601String()}',
    );
  }

  /// Share a single log entry
  static void shareLog(NetworkLogModel log) {
    final jsonData = const JsonEncoder.withIndent('  ').convert({
      'method': log.method,
      'url': log.url,
      'timestamp': log.timestamp.toIso8601String(),
      'statusCode': log.statusCode,
      'statusText': log.statusText,
      'duration': log.duration?.inMilliseconds,
      'headers': log.headers,
      'requestBody': log.requestBody,
      'responseBody': log.responseBody,
      'error': log.error,
    });

    Share.share(
      jsonData,
      subject:
          '${log.method.toUpperCase()} ${getEndpointName(log.url)} - ${log.statusText}',
    );
  }
}
