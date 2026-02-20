import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import 'insights_page.dart';
import 'search_page.dart';
import 'notification_settings_page.dart';
import 'login_page.dart';
import 'holiday_calendar_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentVisualTheme = ref.watch(visualThemeProvider);
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final totalEvents = ref.watch(eventProvider).events.length;
    final completedEvents = ref.watch(eventProvider).completedEvents.length;
    final authState = ref.watch(authStateProvider);
    final user = authState.value; // StreamProvider's value
    final isGuest = user == null;
    final isLoading = authState.isLoading;
    final hasUnsynced = ref.watch(eventProvider).hasUnsyncedEvents;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, ref, user, isGuest, isLoading),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsGrid(context, totalEvents, completedEvents, isGuest),
                const SizedBox(height: 48),

                if (isGuest) ...[
                  _buildSyncPromoCard(context),
                  const SizedBox(height: 48),
                ] else if (hasUnsynced) ...[
                  _buildBackupNowCard(context, ref),
                  const SizedBox(height: 48),
                ],

                _buildSectionHeader(context, '01 . PREFERENCES'),
                const SizedBox(height: 20),
                _buildMenuTile(
                  context,
                  title: 'Productivity Insights',
                  subtitle: 'View your temporal flow & stats',
                  icon: Icons.auto_graph_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InsightsPage(),
                    ),
                  ),
                ),
                _buildMenuTile(
                  context,
                  title: 'Holiday Calendar',
                  subtitle: 'Upcoming regional festivities',
                  icon: Icons.public_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HolidayCalendarPage(),
                    ),
                  ),
                ),
                _buildMenuTile(
                  context,
                  title: 'UI Visual Style',
                  subtitle: currentVisualTheme.displayName,
                  icon: Icons.auto_awesome_mosaic_rounded,
                  onTap: () => _showStylePicker(context, ref, themeNotifier),
                ),
                _buildMenuTile(
                  context,
                  title: 'Theme Mode',
                  subtitle: currentTheme.displayName,
                  icon: Icons.dark_mode_rounded,
                  onTap: () => _showThemePicker(context, ref, themeNotifier),
                ),

                const SizedBox(height: 48),
                _buildSectionHeader(context, '02 . ACCOUNT & SECURITY'),
                const SizedBox(height: 20),
                _buildMenuTile(
                  context,
                  title: 'Cloud Sync & Backup',
                  subtitle: isGuest
                      ? 'Login to sync your data'
                      : 'Pulse your manifest to the stars',
                  icon: Icons.cloud_sync_rounded,
                  onTap: isGuest
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        )
                      : () async {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Syncing with cosmic database...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          await ref
                              .read(eventProvider.notifier)
                              .syncLocalToCloud(); // Push local
                          await ref
                              .read(eventProvider.notifier)
                              .refresh(); // Pull cloud
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sync Complete. Your legacy is secure.',
                                ),
                              ),
                            );
                          }
                        },
                ),
                _buildMenuTile(
                  context,
                  title: 'Notification Settings',
                  subtitle: 'Custom alerts & reminders',
                  icon: Icons.notifications_active_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage(),
                    ),
                  ),
                ),
                _buildMenuTile(
                  context,
                  title: 'Privacy Policy',
                  subtitle: 'How we protect your data',
                  icon: Icons.security_rounded,
                  onTap: () {},
                ),

                const SizedBox(height: 48),
                _buildSectionHeader(context, '03 . APP INFO'),
                const SizedBox(height: 20),
                _buildMenuTile(
                  context,
                  title: 'Calendar Craft',
                  subtitle: 'v1.1.0 Premium Gold',
                  icon: Icons.info_rounded,
                  onTap: null,
                ),

                const SizedBox(height: 64),
                if (!isGuest) _buildSignOutButton(context, ref),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isGuest,
    bool isLoading,
  ) {
    if (isLoading) {
      return SliverAppBar(
        expandedHeight: 320,
        pinned: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        flexibleSpace: const Center(child: CircularProgressIndicator()),
      );
    }
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const SearchPage()));
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isGuest
                            ? Theme.of(context).colorScheme.outlineVariant
                            : Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      backgroundImage: (!isGuest && user.photoURL != null)
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: (isGuest || user.photoURL == null)
                          ? Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isGuest
                      ? 'GUEST CREATOR'
                      : (user.displayName ?? 'MAKER').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGuest ? 'Offline Mode' : (user.email ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                if (!isGuest) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PREMIUM GOLD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCollapsed =
                constraints.maxHeight <=
                kToolbarHeight + (MediaQuery.of(context).padding.top);
            return Opacity(
              opacity: isCollapsed ? 1.0 : 0.0,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CALENDAR CRAFT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Self Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    int total,
    int completed,
    bool isGuest,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            total.toString(),
            'TASKS',
            Icons.grid_view_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            completed.toString(),
            'DONE',
            Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            isGuest ? 'FREE' : 'PRO',
            'TIER',
            Icons.verified_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncPromoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_rounded,
            color: Colors.orangeAccent,
            size: 40,
          ),
          const SizedBox(height: 24),
          const Text(
            'Sync Your Legacy',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep your events synchronized across all devices with Google Cloud.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const LoginPage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              foregroundColor: Theme.of(context).colorScheme.surface,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'ACTIVATE CLOUD SYNC',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupNowCard(BuildContext context, WidgetRef ref) {
    final eventNotifier = ref.read(eventProvider.notifier);
    final eventState = ref.watch(eventProvider);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.backup_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 24),
          const Text(
            'Local Data Found',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Found events created in guest mode. Backup them now to your official account to prevent data loss.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: eventState.isLoading
                ? null
                : () async {
                    await eventNotifier.syncLocalToCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Backup successful! Manifest synced.'),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: eventState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'BACKUP TO CLOUD NOW',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios_rounded, size: 14)
            : null,
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () => _showLogoutDialog(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent, width: 2),
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: const Text(
        'DISCONNECT ACCOUNT',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
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
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
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
                      ? Theme.of(context).colorScheme.onSurface
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final hasUnsynced = ref.watch(eventProvider).hasUnsyncedEvents;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: Text(
          hasUnsynced
              ? '⚠️ You have unsynced events. Signing out will clear them from this device. Please backup your data first if you want to keep them.'
              : 'Syncing will be paused. Your manifest remains safe in the cloud.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
              Navigator.pop(context);
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: hasUnsynced ? Colors.orangeAccent : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
