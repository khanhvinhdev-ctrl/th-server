import 'package:flutter/material.dart';

class EngineControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onRestart;

  const EngineControls({
    super.key,
    this.isRunning = false,
    this.onStart,
    this.onStop,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isRunning ? null : onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Engine'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isRunning ? onStop : null,
            icon: const Icon(Icons.stop),
            label: const Text('Stop Engine'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isRunning ? onRestart : null,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Restart Engine'),
          ),
        ),
      ],
    );
  }
}