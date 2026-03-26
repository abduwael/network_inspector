import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../models/network_log_model.dart';
import '../network_inspector_main.dart';
import '../utils/network_inspector_helpers.dart';
import 'network_inspector_log_details.dart';

/// Individual log card widget for Network Inspector
class NetworkInspectorLogCard extends StatelessWidget {
  final NetworkLogModel log;

  const NetworkInspectorLogCard({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final color = NetworkInspectorHelpers.getStatusColor(log);
    final statusIcon = NetworkInspectorHelpers.getStatusIcon(log);
    final showShareButton = NetworkInspector.config.showShareButton;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row with share button
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w, top: 12.h),
            child: Row(
              children: [
                // Status icon
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(statusIcon, color: color, size: 22.sp),
                ),
                Gap(12.w),
                // Title and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          log.statusText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Gap(8.h),
                      Text(
                        '${log.method.toUpperCase()} ${NetworkInspectorHelpers.getEndpointName(log.url)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Share button
                if (showShareButton)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => NetworkInspectorHelpers.shareLog(log),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          size: 20.sp,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Expandable details section
          Localizations.override(
            context: context,
            locale: const Locale('en'),
            child: Theme(
              data: ThemeData().copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
                childrenPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                title: Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 14.sp, color: Colors.grey.shade500),
                    Gap(4.w),
                    Text(
                      log.formattedTimestamp,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Gap(16.w),
                    if (log.duration != null) ...[
                      Icon(Icons.timer_outlined,
                          size: 14.sp, color: Colors.grey.shade500),
                      Gap(4.w),
                      Text(
                        '${log.duration!.inMilliseconds}ms',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: NetworkInspectorHelpers.getDurationColor(
                            log.duration!.inMilliseconds,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                children: [
                  NetworkInspectorLogDetails(log: log),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
