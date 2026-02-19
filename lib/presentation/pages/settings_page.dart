import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/hive_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentVisualTheme = ref.watch(visualThemeProvider);
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // UI Style Section (From Stitch Designs)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UI Style (Designs from Stitch)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...VisualTheme.values.map(
                    (v) => RadioListTile<VisualTheme>(
                      title: Text(v.displayName),
                      value: v,
                      groupValue: currentVisualTheme,
                      secondary: Icon(_getIconForVisual(v)),
                      onChanged: (value) {
                        if (value != null) {
                          themeNotifier.setVisualTheme(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Theme Mode Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<AppTheme>(
                    title: const Text('Light'),
                    value: AppTheme.light,
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.setTheme(value);
                      }
                    },
                  ),
                  RadioListTile<AppTheme>(
                    title: const Text('Dark'),
                    value: AppTheme.dark,
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.setTheme(value);
                      }
                    },
                  ),
                  RadioListTile<AppTheme>(
                    title: const Text('System'),
                    subtitle: const Text('Follow device theme'),
                    value: AppTheme.system,
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.setTheme(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Allow app to send notifications'),
                    value: true, // TODO: Get from settings
                    onChanged: (value) async {
                      // TODO: Save to settings
                      if (value) {
                        await NotificationService().requestPermissions();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Notification Settings'),
                    subtitle: const Text('Configure notification preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to detailed notification settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Data Management Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Export Events'),
                    subtitle: const Text('Export all events to JSON file'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      try {
                        await HiveService.exportData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export feature coming soon'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Import Events'),
                    subtitle: const Text('Import events from JSON file'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Import feature coming soon'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Backup Data'),
                    subtitle: const Text('Create backup of all app data'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      try {
                        await HiveService.exportData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Backup feature coming soon'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Backup failed: $e')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore Data'),
                    subtitle: const Text('Restore from backup file'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement restore from backup
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Restore feature coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Storage Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Clear All Data'),
                    subtitle: const Text('Delete all events and settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All Data'),
                          content: const Text(
                            'This will delete all events, holidays, and settings. This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await HiveService.clearAll();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All data cleared')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to clear data: $e'),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('App Version'),
                    subtitle: const Text('Calendar Craft v1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('About Calendar Craft'),
                    subtitle: const Text(
                      'A modern calendar and event management app',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Calendar Craft',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(Icons.calendar_today),
                        children: [
                          const Text(
                            'Built with Flutter and clean architecture',
                          ),
                          const SizedBox(height: 8),
                          const Text('Features:'),
                          const Text(
                            '• Calendar views (Monthly, Weekly, Daily)',
                          ),
                          const Text('• Event management'),
                          const Text('• Local notifications'),
                          const Text('• Theme switching'),
                          const Text('• Data export/import'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForVisual(VisualTheme theme) {
    switch (theme) {
      case VisualTheme.monthly:
        return Icons.calendar_month;
      case VisualTheme.bento:
        return Icons.grid_view;
      case VisualTheme.cyber:
        return Icons.rocket_launch;
    }
  }
}
