# api_track_inspector

Inspect every API call in minutes, not hours.  
`api_track_inspector` adds a draggable in-app monitor with request details, timing, errors, and sharing, with quick integration for GetConnect, Dio, and `package:http`.

No setup overhead:
- Initialize once.
- Wrap your app with `NetworkInspector.wrapWithFAB`.
- Plug in your client interceptors (`onRequest`, `onResponse`) or manual hooks (`logRequest`, `logResponse`).

[![pub package](https://img.shields.io/pub/v/api_track_inspector.svg)](https://pub.dev/packages/api_track_inspector)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Screenshots & demo

Request list with stats, success/error counts, timing, and share actions:

![Network Inspector — request list](https://raw.githubusercontent.com/abduwael/network_inspector/master/doc/screenshots/request_list.png)

Expanded entry: full URL, status code, and headers (with copy actions):

![Network Inspector — request details](https://raw.githubusercontent.com/abduwael/network_inspector/master/doc/screenshots/request_details.png)

**Video:** [Open demo walkthrough (MP4)](https://raw.githubusercontent.com/abduwael/network_inspector/master/doc/demo.mp4) — opens or downloads depending on your browser. For an embedded player on pub.dev, upload the same clip to YouTube (or similar) and add a link with a thumbnail.

## Quick AI prompt

Copy/paste this into your AI assistant:

```text
Integrate `api_track_inspector` into my Flutter app with dev-only visibility.
Requirements:
1) Initialize with NetworkInspector.init(enabled: AppConfig.isDev) in startup.
2) Optionally configure maxLogs, colors, FAB position, and showShareButton.
3) Wrap app root using NetworkInspector.wrapWithFAB(child) in MaterialApp/GetMaterialApp builder.
4) If project uses GetConnect, add NetworkInspector.onRequest/onResponse interceptors.
5) If project uses Dio or package:http, wire NetworkInspector.logRequest/logResponse manually.
6) Keep release builds free from inspector UI/overhead.
```

## Why use it

- Capture request/response data while testing APIs.
- Keep debugging UI inside the app (no external proxy needed).
- Integrate quickly with GetConnect (`onRequest`, `onResponse`) or manually via `logRequest`, `logResponse`.

## Installation

### 1) Install from pub.dev (primary)

```yaml
dependencies:
  api_track_inspector: ^1.1.7
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
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final isDevFlavor = flavor == 'dev';

  NetworkInspector.init(
    enabled: kDebugMode && isDevFlavor, // visible only in debug + dev flavor
    maxLogs: 100,
  );
  runApp(const MyApp());
}
```

### Initialize with your flavor flag (dev only)

If your app already has a config like `AppConfig.isDev`, use:

```dart
import 'package:api_track_inspector/api_track_inspector.dart';

void main() {
  NetworkInspector.init(
    enabled: AppConfig.isDev,
  );
  runApp(const MyApp());
}
```

With optional configuration features:

```dart
NetworkInspector.init(
  enabled: AppConfig.isDev,
  maxLogs: 100,
  primaryColor: const Color(0xFF2196F3),
  secondaryColor: const Color(0xFF1565C0),
  fabBottomPosition: 100,
  fabRightPosition: 16,
  showShareButton: true,
);
```

### Real app pattern (MaterialApp + app services)

This is a production-friendly pattern using regular `MaterialApp` with flavor-safe behavior:

```dart
import 'package:flutter/material.dart';
import 'package:api_track_inspector/api_track_inspector.dart';

import 'app/core/config/app_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        // Show inspector FAB only in dev flavor.
        if (AppConfig.isDev && child != null) {
          child = NetworkInspector.wrapWithFAB(child);
        }

        return child ?? const SizedBox.shrink();
      },
    );
  }
}

Future<void> initServices() async {
  // ... your DI/services

  NetworkInspector.init(
    enabled: AppConfig.isDev, // dev flavor only
  );
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
Integrate `api_track_inspector` into my Flutter app with debug + flavor-safe visibility.
Requirements:
1) Call NetworkInspector.init in main() with:
   - enabled: kDebugMode && (current flavor == dev)
   - so inspector appears in dev builds and never in production.
2) Wrap app root using NetworkInspector.wrapWithFAB(child) in MaterialApp/GetMaterialApp builder.
3) If project uses GetConnect, add NetworkInspector.onRequest/onResponse interceptors.
4) If project uses Dio or package:http, wire NetworkInspector.logRequest/logResponse manually.
5) Keep the integration production-safe with zero release visibility/overhead.
```

## Notes

- Recommended for development and QA builds.
- For production apps, keep inspector disabled (for example: `enabled: kDebugMode && flavor == 'dev'`).

## License

MIT License. See `LICENSE`.
