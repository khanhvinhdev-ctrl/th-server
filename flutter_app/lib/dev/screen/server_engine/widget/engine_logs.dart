import 'package:flutter/material.dart';

class EngineLogs extends StatelessWidget {
  final List<String> logs;
  final VoidCallback? onRefresh;
  final VoidCallback? onClear;

  const EngineLogs({
    super.key,
    this.logs = const [],
    this.onRefresh,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Logs',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onClear,
              tooltip: 'Clear logs',
              icon: const Icon(Icons.delete_outline),
            ),
            IconButton(
              onPressed: onRefresh,
              tooltip: 'Refresh logs',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 180,
              maxHeight: 360,
            ),
            padding: const EdgeInsets.all(14),
            color: colorScheme.surfaceContainerHighest,
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      'No logs available.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: SelectableText(
                      logs.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}