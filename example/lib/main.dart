import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:abduwael_network_inspector/abduwael_network_inspector.dart';

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
    return GetMaterialApp(
      title: 'Network Inspector Example',
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
  final _provider = DemoProvider();
  final _client = InspectorHttpClient(http.Client());
  String _result = 'Press a button to generate logs';

  Future<void> _getWithGetConnect() async {
    final response = await _provider.getDemo();
    setState(() {
      _result = 'GetConnect: ${response.statusCode}';
    });
  }

  Future<void> _getWithHttp() async {
    final response = await _client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
    );
    setState(() {
      _result = 'http: ${response.statusCode}';
    });
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
              onPressed: _getWithGetConnect,
              child: const Text('Send request using GetConnect'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _getWithHttp,
              child: const Text('Send request using package:http'),
            ),
            const SizedBox(height: 24),
            Text(_result),
          ],
        ),
      ),
    );
  }
}

class DemoProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://jsonplaceholder.typicode.com';

    httpClient.addRequestModifier<dynamic>((request) {
      return NetworkInspector.onRequest(request);
    });

    httpClient.addResponseModifier<dynamic>((request, response) {
      return NetworkInspector.onResponse(request, response);
    });

    super.onInit();
  }

  Future<Response<dynamic>> getDemo() {
    return get('/todos/1');
  }
}

class InspectorHttpClient extends http.BaseClient {
  final http.Client _inner;

  InspectorHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final start = DateTime.now();
    final logId = NetworkInspector.logRequest(
      method: request.method,
      url: request.url.toString(),
      headers: Map<String, dynamic>.from(request.headers),
    );

    try {
      final streamedResponse = await _inner.send(request);
      final bodyBytes = await streamedResponse.stream.toBytes();
      final bodyText = utf8.decode(bodyBytes, allowMalformed: true);

      if (logId != null) {
        NetworkInspector.logResponse(
          logId: logId,
          statusCode: streamedResponse.statusCode,
          body: bodyText,
          duration: DateTime.now().difference(start),
        );
      }

      return http.StreamedResponse(
        Stream.fromIterable([bodyBytes]),
        streamedResponse.statusCode,
        request: streamedResponse.request,
        headers: streamedResponse.headers,
        reasonPhrase: streamedResponse.reasonPhrase,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        contentLength: streamedResponse.contentLength,
      );
    } catch (e) {
      if (logId != null) {
        NetworkInspector.logResponse(
          logId: logId,
          duration: DateTime.now().difference(start),
          error: e.toString(),
        );
      }
      rethrow;
    }
  }
}
