import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../models/network_log_model.dart';
import '../utils/network_inspector_helpers.dart';

/// Expanded details section for a network log entry
class NetworkInspectorLogDetails extends StatelessWidget {
  final NetworkLogModel log;

  const NetworkInspectorLogDetails({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailSection(
            title: 'Full URL',
            content: log.url,
            icon: Icons.link,
            showCopyButton: true,
          ),
          if (log.statusCode != null) ...[
            Gap(12.h),
            _DetailSection(
              title: 'Status Code',
              content: log.statusCode.toString(),
              icon: Icons.http,
            ),
          ],
          if (log.error != null) ...[
            Gap(12.h),
            _DetailSection(
              title: 'Error',
              content: log.error!,
              icon: Icons.error_outline,
              isError: true,
            ),
          ],
          if (log.headers != null && log.headers!.isNotEmpty) ...[
            Gap(12.h),
            _JsonSection(
              title: 'Request Headers',
              data: log.headers,
              icon: Icons.code,
              backgroundColor: Colors.blueGrey.shade50,
            ),
          ],
          if (log.requestBody != null) ...[
            Gap(12.h),
            _JsonSection(
              title: 'Request Body',
              data: log.requestBody,
              icon: Icons.upload_rounded,
              backgroundColor: Colors.orange.shade50,
            ),
          ],
          if (log.responseBody != null) ...[
            Gap(12.h),
            _JsonSection(
              title: 'Response Body',
              data: log.responseBody,
              icon: Icons.download_rounded,
              backgroundColor: Colors.green.shade50,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isError;
  final bool showCopyButton;

  const _DetailSection({
    required this.title,
    required this.content,
    required this.icon,
    this.isError = false,
    this.showCopyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isError ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isError ? Colors.red : Colors.grey.shade600,
              ),
              Gap(8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isError ? Colors.red : Colors.grey.shade700,
                  ),
                ),
              ),
              if (showCopyButton)
                GestureDetector(
                  onTap: () => NetworkInspectorHelpers.copyToClipboard(content),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(Icons.copy, size: 14.sp, color: Colors.grey),
                  ),
                ),
            ],
          ),
          Gap(8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              color: isError ? Colors.red.shade700 : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _JsonSection extends StatelessWidget {
  final String title;
  final dynamic data;
  final IconData icon;
  final Color backgroundColor;

  const _JsonSection({
    required this.title,
    required this.data,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final formattedData = NetworkInspectorHelpers.formatJson(data);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: Colors.grey.shade700),
                Gap(8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      NetworkInspectorHelpers.copyToClipboard(formattedData),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(Icons.copy,
                        size: 14.sp, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            padding: EdgeInsets.all(12.w),
            child: SingleChildScrollView(
              child: Text(
                formattedData,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
