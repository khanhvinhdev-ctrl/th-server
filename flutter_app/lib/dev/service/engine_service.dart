import 'package:flutter/foundation.dart';

import 'engine_api.dart';

class EngineStatus {
  final bool isRunning;
  final String pid;
  final String uptime;
  final String host;
  final int port;

  const EngineStatus({
    required this.isRunning,
    required this.pid,
    required this.uptime,
    required this.host,
    required this.port,
  });

  factory EngineStatus.fromJson(
    Map<String, dynamic> json, {
    required String host,
    required int port,
  }) {
    return EngineStatus(
      isRunning: json['running'] == true,
      pid: json['pid']?.toString() ?? '-',
      uptime: json['uptime']?.toString() ?? '-',
      host: json['host']?.toString() ?? host,
      port: int.tryParse(
            json['port']?.toString() ?? '',
          ) ??
          port,
    );
  }

  factory EngineStatus.offline({
    required String host,
    required int port,
  }) {
    return EngineStatus(
      isRunning: false,
      pid: '-',
      uptime: '-',
      host: host,
      port: port,
    );
  }
}

class EngineService {
  final EngineApi api;

  EngineService({
    required this.api,
  });

  Future<EngineStatus> getStatus() async {
    debugPrint(
      'THSERVER_ENGINE_SERVICE: getStatus BEGIN',
    );

    try {
      final data = await api.getStatus();

      debugPrint(
        'THSERVER_ENGINE_SERVICE: getStatus RESPONSE = $data',
      );

      return EngineStatus.fromJson(
        data,
        host: api.host,
        port: api.port,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_ENGINE_SERVICE: getStatus FAILED: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return EngineStatus.offline(
        host: api.host,
        port: api.port,
      );
    }
  }

  Future<void> start() async {
    debugPrint(
      'THSERVER_ENGINE_SERVICE: start BEGIN',
    );

    try {
      debugPrint(
        'THSERVER_ENGINE_SERVICE: calling api.start()',
      );

      await api.start();

      debugPrint(
        'THSERVER_ENGINE_SERVICE: api.start() RETURNED',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_ENGINE_SERVICE: start FAILED: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> stop() async {
    debugPrint(
      'THSERVER_ENGINE_SERVICE: stop BEGIN',
    );

    try {
      await api.stop();

      debugPrint(
        'THSERVER_ENGINE_SERVICE: stop RETURNED',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_ENGINE_SERVICE: stop FAILED: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> restart() async {
    debugPrint(
      'THSERVER_ENGINE_SERVICE: restart BEGIN',
    );

    try {
      await api.restart();

      debugPrint(
        'THSERVER_ENGINE_SERVICE: restart RETURNED',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_ENGINE_SERVICE: restart FAILED: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<List<String>> getLogs() async {
    debugPrint(
      'THSERVER_ENGINE_SERVICE: getLogs BEGIN',
    );

    try {
      final logs = await api.getLogs();

      debugPrint(
        'THSERVER_ENGINE_SERVICE: getLogs RETURNED ${logs.length}',
      );

      return logs;
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_ENGINE_SERVICE: getLogs FAILED: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }

  Future<void> clearLogs() async {
    debugPrint(
      'THSERVER_ENGINE_SERVICE: clearLogs BEGIN',
    );

    try {
      await api.clearLogs();

      debugPrint(
        'THSERVER_ENGINE_SERVICE: clearLogs RETURNED',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_ENGINE_SERVICE: clearLogs FAILED: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<bool> waitUntilAvailable() async {
    debugPrint(
      'THSERVER_ENGINE_SERVICE: waiting for control server',
    );
  
    final available =
        await api.waitUntilAvailable();
  
    debugPrint(
      'THSERVER_ENGINE_SERVICE: control server available = $available',
    );
  
    return available;
  }
}