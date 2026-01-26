import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/network_log_model.dart';
import '../network_inspector_main.dart';
import '../services/network_inspector_service.dart';
import 'network_inspector_empty_state.dart';
import 'network_inspector_error_state.dart';
import 'network_inspector_header.dart';
import 'network_inspector_log_card.dart';
import 'network_inspector_statistics_bar.dart';

/// Main Network Inspector Dialog
class NetworkInspectorDialog extends StatelessWidget {
  const NetworkInspectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    NetworkInspectorService? networkInspector;

    try {
      networkInspector = NetworkInspector.service;
    } catch (e) {
      return const NetworkInspectorErrorState();
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 16,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const NetworkInspectorHeader(),
            Expanded(
              child: Obx(() {
                final logs = networkInspector!.logs;
                final stats = networkInspector.getStatistics();
                return Column(
                  children: [
                    NetworkInspectorStatisticsBar(
                      stats: stats,
                      networkInspector: networkInspector,
                    ),
                    Expanded(
                      child: logs.isEmpty
                          ? const NetworkInspectorEmptyState()
                          : _NetworkInspectorLogsList(logs: logs),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logs list widget
class _NetworkInspectorLogsList extends StatelessWidget {
  final List<NetworkLogModel> logs;

  const _NetworkInspectorLogsList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return NetworkInspectorLogCard(log: log);
      },
    );
  }
}
