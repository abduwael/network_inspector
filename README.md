# Network Inspector 🌐

A professional API debugging tool for Flutter apps. Captures and displays network requests in real-time with a beautiful UI.

![Network Inspector](https://img.shields.io/badge/Flutter-Package-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Features ✨

- 📡 **Real-time request logging** - Captures all HTTP requests automatically
- 🎨 **Beautiful UI** - Professional dialog with statistics and detailed logs
- 📤 **Share logs** - Export individual requests or all logs as JSON
- 🔍 **Request details** - View headers, request body, response body, timing
- ⚡ **Easy integration** - Just 3 lines to set up
- 🎯 **Configurable** - Customize colors, position, max logs, and more

## Screenshots

```
┌─────────────────────────────────────┐
│ 🌐 Network Inspector                │
│     API Request Monitor        [X]  │
├─────────────────────────────────────┤
│ Total: 15  Success: 12  Errors: 3   │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ ✓ SUCCESS              [Share] │ │
│ │ POST /api/login                │ │
│ │ 10:30:45 • 245ms         ▼     │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ✗ ERROR                [Share] │ │
│ │ GET /api/users                 │ │
│ │ 10:30:42 • 1250ms        ▼     │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Installation 📦

### Option 1: Git URL (Recommended for private packages)

```yaml
dependencies:
  network_inspector:
    git:
      url: https://github.com/your-org/network_inspector.git
      ref: main
```

### Option 2: Local path

```yaml
dependencies:
  network_inspector:
    path: ../packages/network_inspector
```

## Quick Start 🚀

### Step 1: Initialize in main.dart

```dart
import 'package:network_inspector/network_inspector.dart';

void main() {
  // Initialize Network Inspector (only in dev mode)
  NetworkInspector.init(
    enabled: true,  // Set to false in production
    maxLogs: 100,
    primaryColor: Colors.blue,
  );
  
  runApp(MyApp());
}
```

### Step 2: Add FAB overlay in your app

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ... your config
      builder: (context, child) {
        // Add Network Inspector FAB
        child = NetworkInspector.wrapWithFAB(child!);
        return child;
      },
    );
  }
}
```

### Step 3: Add interceptors to your HTTP client

For **GetConnect**:

```dart
class AppProvider extends GetConnect {
  dynamic _pendingRequestBody;

  @override
  void onInit() {
    httpClient.baseUrl = 'https://api.example.com';
    
    // Add Network Inspector interceptors
    httpClient.addRequestModifier<dynamic>((request) {
      NetworkInspector.setRequestBody(_pendingRequestBody);
      _pendingRequestBody = null;
      return NetworkInspector.onRequest(request);
    });
    
    httpClient.addResponseModifier<dynamic>((request, response) {
      return NetworkInspector.onResponse(request, response);
    });
  }

  // Override to capture request body
  @override
  Future<Response<T>> post<T>(String? url, dynamic body, ...) {
    _pendingRequestBody = body;
    return super.post<T>(url, body, ...);
  }

  @override
  Future<Response<T>> put<T>(String url, dynamic body, ...) {
    _pendingRequestBody = body;
    return super.put<T>(url, body, ...);
  }
}
```

For **Dio**:

```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final logId = NetworkInspector.logRequest(
      method: options.method,
      url: options.uri.toString(),
      headers: options.headers.cast<String, dynamic>(),
      body: options.data,
    );
    options.extra['_network_inspector_log_id'] = logId;
    options.extra['_network_inspector_start'] = DateTime.now();
    handler.next(options);
  },
  onResponse: (response, handler) {
    final logId = response.requestOptions.extra['_network_inspector_log_id'];
    final start = response.requestOptions.extra['_network_inspector_start'];
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
    final logId = error.requestOptions.extra['_network_inspector_log_id'];
    final start = error.requestOptions.extra['_network_inspector_start'];
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
));
```

## Configuration Options ⚙️

```dart
NetworkInspector.init(
  enabled: true,              // Enable/disable the inspector
  maxLogs: 100,               // Maximum logs to keep
  primaryColor: Colors.blue,  // Primary theme color
  secondaryColor: Color(0xFF1565C0),  // Gradient secondary color
  fabBottomPosition: 100,     // FAB position from bottom
  fabRightPosition: 16,       // FAB position from right
  showShareButton: true,      // Show share button on each log
);
```

## API Reference 📚

### NetworkInspector

| Method | Description |
|--------|-------------|
| `init()` | Initialize with options |
| `wrapWithFAB(child)` | Wrap widget with FAB overlay |
| `showDialog()` | Manually show the inspector dialog |
| `onRequest(request)` | Request interceptor for GetConnect |
| `onResponse(request, response)` | Response interceptor for GetConnect |
| `logRequest(...)` | Manually log a request |
| `logResponse(...)` | Manually log a response |
| `clearLogs()` | Clear all logs |
| `exportLogs()` | Export logs as JSON string |

## Dependencies 📋

- `get: ^4.6.5` - State management and navigation
- `flutter_screenutil: ^5.9.0` - Responsive UI
- `gap: ^3.0.1` - Spacing widget
- `share_plus: ^7.2.1` - Share functionality

## License 📄

MIT License - feel free to use in your projects!

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.
