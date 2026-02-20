import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/hive_service.dart';
import '../providers/holiday_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentVisualTheme = ref.watch(visualThemeProvider);
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, 'VISUALS'),
                const SizedBox(height: 12),
                _buildSettingTile(
                  context,
                  title: 'UI Design Style',
                  subtitle: currentVisualTheme.displayName,
                  icon: Icons.auto_awesome_mosaic_rounded,
                  onTap: () => _showStylePicker(context, ref, themeNotifier),
                ),
                _buildSettingTile(
                  context,
                  title: 'Theme Mode',
                  subtitle: currentTheme.displayName,
                  icon: Icons.palette_rounded,
                  onTap: () => _showThemePicker(context, ref, themeNotifier),
                ),

                const SizedBox(height: 32),
                _buildSectionHeader(context, 'SYSTEM'),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  context,
                  title: 'Live Reminders',
                  subtitle: 'Show countdowns in notifications',
                  icon: Icons.notifications_active_rounded,
                  value: true,
                  onChanged: (v) async {
                    if (v) await NotificationService().requestPermissions();
                  },
                ),

                const SizedBox(height: 32),
                _buildSectionHeader(context, 'GLOBAL MANIFEST (HOLIDAYS)'),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  context,
                  title: 'Auto Holiday Detection',
                  subtitle: ref.watch(holidayProvider).useDeviceLocation
                      ? (ref.watch(holidayProvider).countryName ??
                            'Detecting location...')
                      : 'Manual detection active',
                  icon: Icons.location_on_rounded,
                  value: ref.watch(holidayProvider).useDeviceLocation,
                  onChanged: (v) => ref
                      .read(holidayProvider.notifier)
                      .setUseDeviceLocation(v),
                ),
                if (!ref.watch(holidayProvider).useDeviceLocation)
                  _buildSettingTile(
                    context,
                    title: 'Select Region',
                    subtitle:
                        ref.watch(holidayProvider).countryName ??
                        'Select your country',
                    icon: Icons.public_rounded,
                    onTap: () => _showCountryPicker(context, ref),
                  ),
                _buildSettingTile(
                  context,
                  title: 'Refresh Holidays',
                  subtitle: 'Manually update registry',
                  icon: Icons.refresh_rounded,
                  onTap: () async {
                    await ref.read(holidayProvider.notifier).refresh();
                    if (context.mounted) {
                      _showStatus(context, 'Holidays synced');
                    }
                  },
                ),

                const SizedBox(height: 32),
                _buildSectionHeader(context, 'MAINTENANCE'),
                const SizedBox(height: 12),
                _buildSettingTile(
                  context,
                  title: 'Cloud Optimization',
                  subtitle: 'Manually sync all records',
                  icon: Icons.cloud_sync_rounded,
                  onTap: () => _showStatus(context, 'Already optimized'),
                ),
                _buildSettingTile(
                  context,
                  title: 'Factory Reset',
                  subtitle: 'Wipe all local records',
                  icon: Icons.delete_forever_rounded,
                  isDestructive: true,
                  onTap: () => _confirmReset(context),
                ),

                _buildSettingTile(
                  context,
                  title: 'App Version',
                  subtitle: 'v1.1.0-Gold',
                  icon: Icons.info_rounded,
                  onTap: null,
                ),

                const SizedBox(height: 32),
                _buildSectionHeader(context, 'DEBUG INFO'),
                const SizedBox(height: 12),
                FutureBuilder<int>(
                  future: HiveService.getAllEvents().then((l) => l.length),
                  builder: (context, snapshot) => _buildSettingTile(
                    context,
                    title: 'Stored Events',
                    subtitle: '${snapshot.data ?? 0} manifest records',
                    icon: Icons.storage_rounded,
                    onTap: null,
                  ),
                ),
                FutureBuilder<int>(
                  future: HiveService.getAllHolidays().then((l) => l.length),
                  builder: (context, snapshot) => _buildSettingTile(
                    context,
                    title: 'Stored Holidays',
                    subtitle: '${snapshot.data ?? 0} global records',
                    icon: Icons.public_rounded,
                    onTap: null,
                  ),
                ),
                if (ref.watch(holidayProvider).error != null)
                  _buildSettingTile(
                    context,
                    title: 'Location Error',
                    subtitle: ref.watch(holidayProvider).error!,
                    icon: Icons.error_outline_rounded,
                    onTap: () => ref
                        .read(holidayProvider.notifier)
                        .detectAndFetchHolidays(),
                  ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendar Craft',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            Text(
              'Craft Settings',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.5,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.redAccent
        : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: isDestructive ? Colors.redAccent : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios_rounded, size: 14)
            : null,
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }

  void _showStylePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeNotifier notifier,
  ) {
    _showPremiumPicker(
      context,
      title: 'UI Design Style',
      options: VisualTheme.values
          .map(
            (v) => _PickerOption(
              title: v.displayName,
              isSelected: ref.watch(visualThemeProvider) == v,
              onTap: () => notifier.setVisualTheme(v),
            ),
          )
          .toList(),
    );
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeNotifier notifier,
  ) {
    _showPremiumPicker(
      context,
      title: 'Theme Mode',
      options: AppTheme.values
          .map(
            (t) => _PickerOption(
              title: t.displayName,
              isSelected: ref.watch(themeProvider) == t,
              onTap: () => notifier.setTheme(t),
            ),
          )
          .toList(),
    );
  }

  void _showPremiumPicker(
    BuildContext context, {
    required String title,
    required List<_PickerOption> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map(
              (opt) => ListTile(
                onTap: () {
                  opt.onTap();
                  Navigator.pop(context);
                },
                leading: Icon(
                  opt.isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: opt.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                title: Text(
                  opt.title,
                  style: TextStyle(
                    fontWeight: opt.isSelected
                        ? FontWeight.w900
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context, WidgetRef ref) {
    const countries = {
      'BD': 'Bangladesh',
      'US': 'United States',
      'GB': 'United Kingdom',
      'IN': 'India',
      'CA': 'Canada',
      'AU': 'Australia',
      'DE': 'Germany',
      'FR': 'France',
      'JP': 'Japan',
      'BR': 'Brazil',
    };

    _showPremiumPicker(
      context,
      title: 'Select Region',
      options: countries.entries
          .map(
            (e) => _PickerOption(
              title: e.value,
              isSelected: ref.watch(holidayProvider).countryCode == e.key,
              onTap: () => ref
                  .read(holidayProvider.notifier)
                  .fetchHolidays(e.key, e.value),
            ),
          )
          .toList(),
    );
  }

  void _showStatus(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Craft Reset'),
        content: const Text(
          'This will permanently delete all your events and preferences. This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset Everything',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HiveService.clearAll();
      if (context.mounted) _showStatus(context, 'Reset complete');
    }
  }
}

class _PickerOption {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  _PickerOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
}
