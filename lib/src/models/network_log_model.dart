/// Model class to represent a network request/response
class NetworkLogModel {
  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, dynamic>? headers;
  final dynamic requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final Duration? duration;
  final String? error;

  NetworkLogModel({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.url,
    this.headers,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    this.duration,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'method': method,
      'url': url,
      'headers': headers,
      'requestBody': requestBody,
      'statusCode': statusCode,
      'responseBody': responseBody,
      'duration': duration?.inMilliseconds,
      'error': error,
    };
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String get statusText {
    if (error != null) return 'ERROR';
    if (statusCode == null) return 'PENDING';
    if (statusCode! >= 200 && statusCode! < 300) return 'SUCCESS';
    if (statusCode! >= 400 && statusCode! < 500) return 'CLIENT ERROR';
    if (statusCode! >= 500) return 'SERVER ERROR';
    return 'UNKNOWN';
  }

  /// Create a copy with updated values
  NetworkLogModel copyWith({
    String? id,
    DateTime? timestamp,
    String? method,
    String? url,
    Map<String, dynamic>? headers,
    dynamic requestBody,
    int? statusCode,
    dynamic responseBody,
    Duration? duration,
    String? error,
  }) {
    return NetworkLogModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      requestBody: requestBody ?? this.requestBody,
      statusCode: statusCode ?? this.statusCode,
      responseBody: responseBody ?? this.responseBody,
      duration: duration ?? this.duration,
      error: error ?? this.error,
    );
  }
}
