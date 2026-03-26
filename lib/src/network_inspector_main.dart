import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import 'config/network_inspector_config.dart';
import 'services/network_inspector_service.dart';
import 'widgets/network_inspector_dialog.dart';

/// Main entry point for Network Inspector
///
/// Usage:
/// ```dart
/// // 1. Initialize in main.dart
/// NetworkInspector.init(enabled: true);
///
/// // 2. Wrap your app with FAB
/// NetworkInspector.wrapWithFAB(child)
///
/// // 3. Add to your HTTP interceptors
/// NetworkInspector.onRequest(request, body: requestBody);
/// NetworkInspector.onResponse(request, response);
/// ```
class NetworkInspector {
  NetworkInspector._();

  static NetworkInspectorService? _service;
  static NetworkInspectorConfig _config = NetworkInspectorConfig.defaultConfig;

  /// Temporary storage for request body
  static dynamic _pendingRequestBody;

  /// Get the service instance
  static NetworkInspectorService get service {
    if (_service == null) {
      throw Exception(
        'NetworkInspector not initialized. Call NetworkInspector.init() first.',
      );
    }
    return _service!;
  }

  /// Check if initialized
  static bool get isInitialized => _service != null;

  /// Check if enabled
  static bool get isEnabled => _config.enabled && isInitialized;

  /// Get current config
  static NetworkInspectorConfig get config => _config;

  /// Initialize Network Inspector
  ///
  /// Call this in your main.dart before runApp:
  /// ```dart
  /// void main() {
  ///   NetworkInspector.init(enabled: kDebugMode);
  ///   runApp(MyApp());
  /// }
  /// ```
  static void init({
    bool enabled = true,
    int maxLogs = 100,
    Color primaryColor = const Color(0xFF2196F3),
    Color secondaryColor = const Color(0xFF1565C0),
    double fabBottomPosition = 100,
    double fabRightPosition = 16,
    bool showShareButton = true,
  }) {
    _config = NetworkInspectorConfig(
      enabled: enabled,
      maxLogs: maxLogs,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      fabBottomPosition: fabBottomPosition,
      fabRightPosition: fabRightPosition,
      showShareButton: showShareButton,
    );

    if (enabled) {
      _service = Get.put(NetworkInspectorService());
      _service!.initialize(_config);
      debugPrint('🌐 Network Inspector Ready');
    }
  }

  /// Initialize with custom config
  static void initWithConfig(NetworkInspectorConfig config) {
    _config = config;
    if (config.enabled) {
      _service = Get.put(NetworkInspectorService());
      _service!.initialize(_config);
      debugPrint('🌐 Network Inspector Ready');
    }
  }

  /// Wrap a widget with the Network Inspector FAB overlay
  ///
  /// Use in your app's builder:
  /// ```dart
  /// builder: (context, child) {
  ///   child = NetworkInspector.wrapWithFAB(child!);
  ///   return child;
  /// }
  /// ```
  static Widget wrapWithFAB(Widget child) {
    if (!isEnabled) return child;

    return _DraggableInspectorOverlay(config: _config, child: child);
  }

  /// Show the Network Inspector dialog
  static void showDialog() {
    if (!isEnabled) return;

    // Prevent opening multiple dialogs
    if (_service!.isDialogOpen) return;

    _service!.isDialogOpen = true;

    Get.dialog(const NetworkInspectorDialog(), barrierDismissible: true).then((
      _,
    ) {
      _service!.isDialogOpen = false;
    });
  }

  /// Store request body for the next request
  /// Call this before making POST/PUT/PATCH requests
  static void setRequestBody(dynamic body) {
    if (!isEnabled) return;
    _pendingRequestBody = body;
  }

  /// Intercept outgoing request (for GetConnect)
  ///
  /// Add to your httpClient:
  /// ```dart
  /// httpClient.addRequestModifier((request) => NetworkInspector.onRequest(request));
  /// ```
  static FutureOr<Request<dynamic>> onRequest(Request<dynamic> request) {
    if (!isEnabled) return request;

    try {
      final requestBody = _pendingRequestBody;
      _pendingRequestBody = null;

      final logId = _service!.logRequest(
        method: request.method.toString(),
        url: request.url.toString(),
        headers: Map<String, dynamic>.from(request.headers),
        body: requestBody,
      );

      // Store logId in request headers for response matching
      request.headers['_network_inspector_log_id'] = logId;
      request.headers['_network_inspector_start_time'] =
          DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      debugPrint('NetworkInspector onRequest error: $e');
    }

    return request;
  }

  /// Intercept incoming response (for GetConnect)
  ///
  /// Add to your httpClient:
  /// ```dart
  /// httpClient.addResponseModifier((req, res) => NetworkInspector.onResponse(req, res));
  /// ```
  static FutureOr<Response<dynamic>> onResponse(
    Request<dynamic> request,
    Response<dynamic> response,
  ) {
    if (!isEnabled) return response;

    try {
      final logId = request.headers['_network_inspector_log_id'];
      final startTimeStr = request.headers['_network_inspector_start_time'];

      if (logId != null && startTimeStr != null) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(startTimeStr),
        );
        final duration = DateTime.now().difference(startTime);

        _service!.updateLogWithResponse(
          logId,
          statusCode: response.statusCode,
          responseBody: response.body,
          duration: duration,
          error: response.hasError ? response.statusText : null,
        );
      }
    } catch (e) {
      debugPrint('NetworkInspector onResponse error: $e');
    }

    return response;
  }

  /// Log a request manually (for non-GetConnect HTTP clients)
  ///
  /// ```dart
  /// final logId = NetworkInspector.logRequest(
  ///   method: 'POST',
  ///   url: 'https://api.example.com/data',
  ///   headers: {'Authorization': 'Bearer ...'},
  ///   body: {'key': 'value'},
  /// );
  ///
  /// // After response:
  /// NetworkInspector.logResponse(
  ///   logId: logId,
  ///   statusCode: 200,
  ///   body: responseData,
  ///   duration: Duration(milliseconds: 250),
  /// );
  /// ```
  static String? logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!isEnabled) return null;
    return _service!.logRequest(
      method: method,
      url: url,
      headers: headers,
      body: body,
    );
  }

  /// Log a response manually
  static void logResponse({
    required String logId,
    int? statusCode,
    dynamic body,
    Duration? duration,
    String? error,
  }) {
    if (!isEnabled) return;
    _service!.updateLogWithResponse(
      logId,
      statusCode: statusCode,
      responseBody: body,
      duration: duration,
      error: error,
    );
  }

  /// Clear all logs
  static void clearLogs() {
    if (!isEnabled) return;
    _service!.clearLogs();
  }

  /// Export logs as JSON string
  static String? exportLogs() {
    if (!isEnabled) return null;
    return _service!.exportLogsAsJson();
  }
}

/// Draggable overlay hosting the inspector FAB (chat-head style).
class _DraggableInspectorOverlay extends StatefulWidget {
  final Widget child;
  final NetworkInspectorConfig config;

  const _DraggableInspectorOverlay({required this.child, required this.config});

  @override
  State<_DraggableInspectorOverlay> createState() =>
      _DraggableInspectorOverlayState();
}

class _DraggableInspectorOverlayState
    extends State<_DraggableInspectorOverlay> {
  static const double _fabSize = 56;
  late double _left;
  late double _top;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        if (!_initialized) {
          final initialLeft = width - widget.config.fabRightPosition - _fabSize;
          final initialTop =
              height - widget.config.fabBottomPosition - _fabSize;
          _left = initialLeft.clamp(0.0, width - _fabSize);
          _top = initialTop.clamp(0.0, height - _fabSize);
          _initialized = true;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            Positioned(
              left: _left,
              top: _top,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _left = (_left + details.delta.dx).clamp(
                      0.0,
                      width - _fabSize,
                    );
                    _top = (_top + details.delta.dy).clamp(
                      0.0,
                      height - _fabSize,
                    );
                  });
                },
                onPanEnd: (_) => _snapToNearestEdge(width, height),
                child: FloatingActionButton(
                  onPressed: NetworkInspector.showDialog,
                  backgroundColor: widget.config.primaryColor,
                  child: const Icon(Icons.network_check, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _snapToNearestEdge(double width, double height) {
    setState(() {
      final bool snapLeft = _left <= (width - _fabSize) / 2;
      _left = snapLeft ? 0.0 : width - _fabSize;
      _top = _top.clamp(0.0, height - _fabSize);
    });
  }
}
