import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeServerService {
  static const MethodChannel _channel =
      MethodChannel('thserver/native');

  Future<bool> startServer() async {
    debugPrint(
      'THSERVER_NATIVE: invokeMethod(startServer) BEGIN',
    );

    try {
      final result = await _channel
          .invokeMethod<bool>('startServer')
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        'THSERVER_NATIVE: invokeMethod(startServer) RESULT = $result',
      );

      return result ?? false;
    } on TimeoutException catch (error) {
      debugPrint(
        'THSERVER_NATIVE: startServer TIMEOUT: $error',
      );

      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_NATIVE: startServer ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<bool> stopServer() async {
    debugPrint(
      'THSERVER_NATIVE: invokeMethod(stopServer) BEGIN',
    );

    try {
      final result = await _channel
          .invokeMethod<bool>('stopServer')
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        'THSERVER_NATIVE: invokeMethod(stopServer) RESULT = $result',
      );

      return result ?? false;
    } catch (error, stackTrace) {
      debugPrint(
        'THSERVER_NATIVE: stopServer ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}