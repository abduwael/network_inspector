# api_track_inspector

Flutter package to inspect HTTP traffic during development.  
It provides a draggable in-app FAB, a request log dialog, and helpers for GetConnect plus manual logging hooks for Dio and `package:http`.

[![pub package](https://img.shields.io/pub/v/api_track_inspector.svg)](https://pub.dev/packages/api_track_inspector)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Why use it

- Capture request/response data while testing APIs.
- Keep debugging UI inside the app (no external proxy needed).
- Integrate quickly with GetConnect (`onRequest`, `onResponse`) or manually via `logRequest`, `logResponse`.

## Installation

### 1) Install from pub.dev (primary)

```yaml
dependencies:
  api_track_inspector: ^1.1.5
```

### 2) Install from Git (secondary)

```yaml
dependencies:
  api_track_inspector:
    git:
      url: https://github.com/abduwael/network_inspector.git
      ref: master
```

Then run:

```bash
flutter pub get
```

## Quick start

### Initialize once

```dart
import 'package:flutter/foundation.dart';
import 'package:api_track_inspector/api_track_inspector.dart';

void main() {
  NetworkInspector.init(
    enabled: kDebugMode, // recommended: debug only
    maxLogs: 100,
  );
  runApp(const MyApp());
}
```

### Add floating inspector button

```dart
MaterialApp(
  builder: (context, child) {
    if (child == null) return const SizedBox.shrink();
    return NetworkInspector.wrapWithFAB(child);
  },
);
```

## Integration guides

### GetConnect interceptor usage

`onRequest` reads a temporary body value, so set it before body-based calls.

```dart
import 'package:get/get.dart';
import 'package:api_track_inspector/api_track_inspector.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.addRequestModifier<dynamic>((request) {
      return NetworkInspector.onRequest(request);
    });

    httpClient.addResponseModifier<dynamic>((request, response) {
      return NetworkInspector.onResponse(request, response);
    });

    super.onInit();
  }

  Future<Response<T>> postWithInspector<T>(String url, dynamic body) {
    NetworkInspector.setRequestBody(body);
    return post<T>(url, body);
  }

  Future<Response<T>> putWithInspector<T>(String url, dynamic body) {
    NetworkInspector.setRequestBody(body);
    return put<T>(url, body);
  }
}
```

### Dio interceptor usage

```dart
import 'package:dio/dio.dart';
import 'package:api_track_inspector/api_track_inspector.dart';

final dio = Dio();

dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      final logId = NetworkInspector.logRequest(
        method: options.method,
        url: options.uri.toString(),
        headers: Map<String, dynamic>.from(options.headers),
        body: options.data,
      );
      options.extra['_inspectorLogId'] = logId;
      options.extra['_inspectorStart'] = DateTime.now();
      handler.next(options);
    },
    onResponse: (response, handler) {
      final logId = response.requestOptions.extra['_inspectorLogId'] as String?;
      final start = response.requestOptions.extra['_inspectorStart'] as DateTime?;
      if (logId != null && start != null) {
        NetworkInspector.logResponse(
          logId: logId,
          statusCode: response.statusCode,
          body: response.data,
          duration: DateTime.now().difference(start),
        );
      }
      handler.next(response);
    },
    onError: (error, handler) {
      final logId = error.requestOptions.extra['_inspectorLogId'] as String?;
      final start = error.requestOptions.extra['_inspectorStart'] as DateTime?;
      if (logId != null && start != null) {
        NetworkInspector.logResponse(
          logId: logId,
          statusCode: error.response?.statusCode,
          body: error.response?.data,
          duration: DateTime.now().difference(start),
          error: error.message,
        );
      }
      handler.next(error);
    },
  ),
);
```

### package:http wrapped client usage

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:api_track_inspector/api_track_inspector.dart';

class InspectorHttpClient extends http.BaseClient {
  final http.Client _inner;
  InspectorHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startedAt = DateTime.now();

    final logId = NetworkInspector.logRequest(
      method: request.method,
      url: request.url.toString(),
      headers: Map<String, dynamic>.from(request.headers),
    );

    try {
      final streamed = await _inner.send(request);
      final duration = DateTime.now().difference(startedAt);

      final bodyBytes = await streamed.stream.toBytes();
      final bodyText = utf8.decode(bodyBytes, allowMalformed: true);

      if (logId != null) {
        NetworkInspector.logResponse(
          logId: logId,
          statusCode: streamed.statusCode,
          body: bodyText,
          duration: duration,
        );
      }

      return http.StreamedResponse(
        Stream.fromIterable([bodyBytes]),
        streamed.statusCode,
        request: streamed.request,
        headers: streamed.headers,
        reasonPhrase: streamed.reasonPhrase,
        isRedirect: streamed.isRedirect,
        persistentConnection: streamed.persistentConnection,
        contentLength: streamed.contentLength,
      );
    } catch (e) {
      if (logId != null) {
        NetworkInspector.logResponse(
          logId: logId,
          duration: DateTime.now().difference(startedAt),
          error: e.toString(),
        );
      }
      rethrow;
    }
  }
}
```

## API reference

- `init(...)`: initialize the inspector and config.
- `wrapWithFAB(child)`: overlay draggable FAB to open dialog.
- `onRequest(request)`: GetConnect request hook.
- `onResponse(request, response)`: GetConnect response hook.
- `logRequest(...)`: manual request logging (Dio/http/others).
- `logResponse(...)`: manual response/error logging.
- `clearLogs()`: clear in-memory logs.
- `exportLogs()`: export logs JSON string.

## AI quick prompt (copy/paste)

Use this in your AI coding assistant:

```text
Integrate `api_track_inspector` into my Flutter app using debug-only mode.
Requirements:
1) Call NetworkInspector.init(enabled: kDebugMode) in main().
2) Wrap app root using NetworkInspector.wrapWithFAB(child) in MaterialApp/GetMaterialApp builder.
3) If project uses GetConnect, add NetworkInspector.onRequest/onResponse interceptors.
4) If project uses Dio or package:http, wire NetworkInspector.logRequest/logResponse manually.
5) Keep all integration under debug-safe behavior and avoid release overhead.
```

## Notes

- Recommended for development and QA builds.
- For production apps, keep `enabled: false` in release (or `enabled: kDebugMode`).

## License

MIT License. See `LICENSE`.
