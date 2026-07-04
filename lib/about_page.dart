import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app/theme/theme_provider.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.cloud_rounded,
                size: 48,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'News & Weather Hub',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Weather, news and bookmarks in one place',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withOpacity(0.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(
                    isDark ? 'Dark Theme' : 'Light Theme',
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      if (value) {
                        ref.read(themeModeProvider.notifier).setDark();
                      } else {
                        ref.read(themeModeProvider.notifier).setLight();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              final build = snapshot.data?.buildNumber ?? '1';

              return Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.verified_rounded,
                      title: 'Version',
                      value: version,
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    _InfoTile(
                      icon: Icons.build_rounded,
                      title: 'Build Number',
                      value: build,
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    _InfoTile(
                      icon: Icons.cloud_outlined,
                      title: 'Weather',
                      value: 'Enabled',
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    _InfoTile(
                      icon: Icons.article_outlined,
                      title: 'News',
                      value: 'Enabled',
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              isDark ? 'Dark mode is active' : 'Light mode is active',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
    );
  }
}