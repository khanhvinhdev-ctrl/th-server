import 'package:flutter/material.dart';

import '../../service/engine_api.dart';
import '../../service/engine_service.dart';
import '../../service/native_server_service.dart';
import 'widget/engine_controls.dart';
import 'widget/engine_info.dart';
import 'widget/engine_logs.dart';
import 'widget/engine_status_card.dart';

class ServerEngineScreen extends StatefulWidget {
  const ServerEngineScreen({super.key});

  @override
  State<ServerEngineScreen> createState() => _ServerEngineScreenState();
}

class _ServerEngineScreenState extends State<ServerEngineScreen> {
  late final EngineService _engineService;
  late final NativeServerService _nativeServerService;

  bool _isLoading = true;

  EngineStatus? _status;
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();

    _engineService = EngineService(
      api: const EngineApi(
        host: '127.0.0.1',
        port: 8080,
      ),
    );

    _nativeServerService = NativeServerService();

    _load();
  }

  Future<void> _load() async {
    final status = await _engineService.getStatus();
    final logs = await _engineService.getLogs();

    if (!mounted) {
      return;
    }

    setState(() {
      _status = status;
      _logs = logs;
      _isLoading = false;
    });
  }

  
  Future<void> _startEngine() async {
  debugPrint(
    'THSERVER_START_1: _startEngine ENTER',
  );

  final started =
      await _nativeServerService.startServer();

  debugPrint(
    'THSERVER_START_2: native result = $started',
  );

  if (!started) {
    debugPrint(
      'THSERVER_START_3: native start FAILED',
    );
    return;
  }

  debugPrint(
    'THSERVER_START_4: waiting for control server',
  );

  final available =
      await _engineService.waitUntilAvailable();

  if (!available) {
    debugPrint(
      'THSERVER_START_5: control server NOT AVAILABLE',
    );
    return;
  }

  debugPrint(
    'THSERVER_START_6: calling Engine API start',
  );

  await _engineService.start();

  debugPrint(
    'THSERVER_START_7: Engine API start returned',
  );

  for (var i = 0; i < 10; i++) {
    debugPrint(
      'THSERVER_START_8: polling ${i + 1}/10',
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    await _refresh();

    if (_status?.isRunning == true) {
      debugPrint(
        'THSERVER_START_9: Engine is RUNNING',
      );
      break;
    }
  }

  debugPrint(
    'THSERVER_START_10: _startEngine DONE',
  );
  }

  Future<void> _stopEngine() async {
    await _nativeServerService.stopServer();

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    await _refresh();
  }

  Future<void> _restartEngine() async {
    await _nativeServerService.stopServer();

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    final started = await _nativeServerService.startServer();

    if (!started) {
      await _refresh();
      return;
    }

    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      await _refresh();

      if (_status?.isRunning == true) {
        break;
      }
    }
  }

  Future<void> _refresh() async {
    final status = await _engineService.getStatus();
    final logs = await _engineService.getLogs();

    if (!mounted) {
      return;
    }

    setState(() {
      _status = status;
      _logs = logs;
    });
  }

  Future<void> _clearLogs() async {
    await _engineService.clearLogs();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _status == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Engine'),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Server Engine',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rust server engine control and status',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                EngineStatusCard(
                  isRunning: _status!.isRunning,
                ),
                const SizedBox(height: 16),
                EngineInfo(
                  host: _status!.host,
                  port: _status!.port.toString(),
                  pid: _status!.pid,
                  uptime: _status!.uptime,
                ),
                const SizedBox(height: 24),
                Text(
                  'Controls',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                EngineControls(
                  isRunning: _status!.isRunning,
                  onStart: _startEngine,
                  onStop: _stopEngine,
                  onRestart: _restartEngine,
                ),
                const SizedBox(height: 28),
                EngineLogs(
                  logs: _logs,
                  onRefresh: _refresh,
                  onClear: _clearLogs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}