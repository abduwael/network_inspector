import 'package:flutter/material.dart';

/// Configuration options for Network Inspector
class NetworkInspectorConfig {
  /// Whether the inspector is enabled
  final bool enabled;

  /// Maximum number of logs to keep
  final int maxLogs;

  /// Primary color for the UI
  final Color primaryColor;

  /// Secondary color for gradients
  final Color secondaryColor;

  /// FAB position from bottom
  final double fabBottomPosition;

  /// FAB position from right
  final double fabRightPosition;

  /// Whether to show the share button on each log card
  final bool showShareButton;

  const NetworkInspectorConfig({
    this.enabled = true,
    this.maxLogs = 100,
    this.primaryColor = const Color(0xFF2196F3),
    this.secondaryColor = const Color(0xFF1565C0),
    this.fabBottomPosition = 100,
    this.fabRightPosition = 16,
    this.showShareButton = true,
  });

  /// Default configuration
  static const NetworkInspectorConfig defaultConfig = NetworkInspectorConfig();

  /// Copy with new values
  NetworkInspectorConfig copyWith({
    bool? enabled,
    int? maxLogs,
    Color? primaryColor,
    Color? secondaryColor,
    double? fabBottomPosition,
    double? fabRightPosition,
    bool? showShareButton,
  }) {
    return NetworkInspectorConfig(
      enabled: enabled ?? this.enabled,
      maxLogs: maxLogs ?? this.maxLogs,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fabBottomPosition: fabBottomPosition ?? this.fabBottomPosition,
      fabRightPosition: fabRightPosition ?? this.fabRightPosition,
      showShareButton: showShareButton ?? this.showShareButton,
    );
  }
}
