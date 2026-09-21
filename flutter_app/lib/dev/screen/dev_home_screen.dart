import 'package:flutter/material.dart';

import '../widget/dev_module_card.dart';
import '../widget/dev_status_card.dart';

class DevHomeScreen extends StatelessWidget {
  const DevHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ThServer · Dev'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Development',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Development tools and server controls',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              const DevStatusCard(),

              const SizedBox(height: 24),

              Text(
                'Modules',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  DevModuleCard(
                    icon: Icons.dns_outlined,
                    title: 'Server Engine',
                  ),
                  DevModuleCard(
                    icon: Icons.storage_outlined,
                    title: 'Database',
                  ),
                  DevModuleCard(
                    icon: Icons.api_outlined,
                    title: 'API',
                  ),
                  DevModuleCard(
                    icon: Icons.cloud_outlined,
                    title: 'Cloudflare Tunnel',
                  ),
                  DevModuleCard(
                    icon: Icons.article_outlined,
                    title: 'Logs',
                  ),
                  DevModuleCard(
                    icon: Icons.memory_outlined,
                    title: 'System',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}