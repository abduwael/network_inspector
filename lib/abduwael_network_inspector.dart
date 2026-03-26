/// Network Inspector - A professional API debugging tool for Flutter
///
/// A beautiful, easy-to-use network inspector that captures and displays
/// HTTP requests in real-time. Perfect for debugging API calls during development.
///
/// ## Quick Start
///
/// 1. Initialize in your main.dart:
/// ```dart
/// void main() {
///   NetworkInspector.init(enabled: true);
///   runApp(MyApp());
/// }
/// ```
///
/// 2. Add the FAB overlay in your app builder:
/// ```dart
/// builder: (context, child) {
///   return NetworkInspector.wrapWithFAB(child!);
/// }
/// ```
///
/// 3. Add interceptors to your HTTP client (GetConnect example):
/// ```dart
/// httpClient.addRequestModifier((request) => NetworkInspector.onRequest(request));
/// httpClient.addResponseModifier((req, res) => NetworkInspector.onResponse(req, res));
/// ```
library abduwael_network_inspector;

export 'src/network_inspector_main.dart';
export 'src/services/network_inspector_service.dart';
export 'src/models/network_log_model.dart';
export 'src/widgets/network_inspector_dialog.dart';
export 'src/config/network_inspector_config.dart';
