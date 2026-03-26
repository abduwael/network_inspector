import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:http/http.dart' as http;
import 'package:api_track_inspector/api_track_inspector.dart';

void main() {
  NetworkInspector.init(
    enabled: kDebugMode,
    maxLogs: 100,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Inspector Example',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return NetworkInspector.wrapWithFAB(child);
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dio = Dio();
  String _result = 'Run any request and open the inspector FAB.';

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio.interceptors.add(
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
          final logId =
              response.requestOptions.extra['_inspectorLogId'] as String?;
          final start =
              response.requestOptions.extra['_inspectorStart'] as DateTime?;
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
          final logId =
              error.requestOptions.extra['_inspectorLogId'] as String?;
          final start =
              error.requestOptions.extra['_inspectorStart'] as DateTime?;
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
  }

  Future<void> _sendWithHttp() async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos/1');
    final startedAt = DateTime.now();

    final logId = NetworkInspector.logRequest(
      method: 'GET',
      url: uri.toString(),
      headers: const {'Accept': 'application/json'},
    );

    try {
      final response = await http.get(uri);
      final duration = DateTime.now().difference(startedAt);

      if (logId != null) {
        NetworkInspector.logResponse(
          logId: logId,
          statusCode: response.statusCode,
          body: response.body,
          duration: duration,
        );
      }

      setState(() {
        _result = 'package:http -> ${response.statusCode} '
            '(${duration.inMilliseconds}ms)';
      });
    } catch (e) {
      if (logId != null) {
        NetworkInspector.logResponse(
          logId: logId,
          duration: DateTime.now().difference(startedAt),
          error: e.toString(),
        );
      }
      setState(() {
        _result = 'package:http failed: $e';
      });
    }
  }

  Future<void> _sendWithDio() async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/posts/1',
      );
      setState(() {
        _result = 'Dio -> ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _result = 'Dio failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Inspector Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _sendWithDio,
              child: const Text('Send with Dio'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _sendWithHttp,
              child: const Text('Send with package:http'),
            ),
            const SizedBox(height: 24),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
