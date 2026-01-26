import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../network_inspector_main.dart';
import '../services/network_inspector_service.dart';
import '../utils/network_inspector_helpers.dart';

/// Statistics bar widget for Network Inspector
class NetworkInspectorStatisticsBar extends StatelessWidget {
  final Map<String, dynamic> stats;
  final NetworkInspectorService networkInspector;

  const NetworkInspectorStatisticsBar({
    super.key,
    required this.stats,
    required this.networkInspector,
  });

  @override
  Widget build(BuildContext context) {
    final config = NetworkInspector.config;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.list_alt_rounded,
                    label: 'Total',
                    value: stats['total'].toString(),
                    color: const Color(0xFF2196F3),
                  ),
                  Gap(12.w),
                  _StatChip(
                    icon: Icons.check_circle_outline,
                    label: 'Success',
                    value: stats['successes'].toString(),
                    color: const Color(0xFF4CAF50),
                  ),
                  Gap(12.w),
                  _StatChip(
                    icon: Icons.error_outline,
                    label: 'Errors',
                    value: stats['errors'].toString(),
                    color: const Color(0xFFF44336),
                  ),
                  Gap(12.w),
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: 'Avg',
                    value: '${stats['averageDurationMs']}ms',
                    color: const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),
          ),
          Gap(8.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.delete_sweep_rounded,
                onTap: () => networkInspector.clearLogs(),
                color: Colors.grey.shade600,
              ),
              Gap(4.w),
              _ActionButton(
                icon: Icons.ios_share_rounded,
                onTap: () =>
                    NetworkInspectorHelpers.exportLogs(networkInspector),
                color: config.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          Gap(6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),
      ),
    );
  }
}
