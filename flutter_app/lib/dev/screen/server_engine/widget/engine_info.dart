import 'package:flutter/material.dart';

class EngineInfo extends StatelessWidget {
  final String host;
  final String port;
  final String pid;
  final String uptime;

  const EngineInfo({
    super.key,
    required this.host,
    required this.port,
    required this.pid,
    required this.uptime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _InfoRow(
              label: 'Host',
              value: host,
            ),
            _InfoRow(
              label: 'Port',
              value: port,
            ),
            _InfoRow(
              label: 'PID',
              value: pid,
            ),
            _InfoRow(
              label: 'Uptime',
              value: uptime,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}