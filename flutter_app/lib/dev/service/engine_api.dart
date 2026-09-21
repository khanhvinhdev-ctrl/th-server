import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class EngineApi {
  final String host;
  final int port;

  const EngineApi({
    required this.host,
    required this.port,
  });

  Uri get _uri => Uri.parse('http://$host:$port');

  Future<bool> isAvailable() async {
    final uri = _uri.resolve('/health');

    developer.log(
      'GET $uri',
      name: 'ThServer.EngineApi',
    );

    try {
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 2),
          );

      developer.log(
        'GET $uri -> ${response.statusCode}: ${response.body}',
        name: 'ThServer.EngineApi',
      );

      return response.statusCode == 200;
    } catch (error) {
      developer.log(
        'GET $uri FAILED: $error',
        name: 'ThServer.EngineApi',
      );

      return false;
    }
  }

  Future<bool> waitUntilAvailable({
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 200),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (await isAvailable()) {
        return true;
      }

      await Future<void>.delayed(interval);
    }

    return false;
  }

  Future<Map<String, dynamic>> getStatus() async {
    final uri = _uri.resolve('/api/engine/status');

    developer.log(
      'GET $uri',
      name: 'ThServer.EngineApi',
    );

    try {
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
          );

      developer.log(
        'GET $uri -> ${response.statusCode}: ${response.body}',
        name: 'ThServer.EngineApi',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to get engine status: ${response.statusCode}',
        );
      }

      return jsonDecode(response.body)
          as Map<String, dynamic>;
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'GET $uri TIMEOUT',
        name: 'ThServer.EngineApi',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'GET $uri FAILED',
        name: 'ThServer.EngineApi',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> start() async {
    await _post('/api/engine/start');
  }

  Future<void> stop() async {
    await _post('/api/engine/stop');
  }

  Future<void> restart() async {
    await _post('/api/engine/restart');
  }

  Future<List<String>> getLogs() async {
    final uri = _uri.resolve('/api/engine/logs');

    developer.log(
      'GET $uri',
      name: 'ThServer.EngineApi',
    );

    try {
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
          );

      developer.log(
        'GET $uri -> ${response.statusCode}: ${response.body}',
        name: 'ThServer.EngineApi',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to get engine logs: ${response.statusCode}',
        );
      }

      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return List<String>.from(
        data['logs'] ?? const [],
      );
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'GET $uri TIMEOUT',
        name: 'ThServer.EngineApi',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'GET $uri FAILED',
        name: 'ThServer.EngineApi',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> clearLogs() async {
    await _post('/api/engine/logs/clear');
  }

  Future<void> _post(String path) async {
    final uri = _uri.resolve(path);

    developer.log(
      'POST $uri',
      name: 'ThServer.EngineApi',
    );

    try {
      final response = await http
          .post(uri)
          .timeout(
            const Duration(seconds: 5),
          );

      developer.log(
        'POST $uri -> ${response.statusCode}: ${response.body}',
        name: 'ThServer.EngineApi',
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Request failed: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'POST $uri TIMEOUT',
        name: 'ThServer.EngineApi',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'POST $uri FAILED',
        name: 'ThServer.EngineApi',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}