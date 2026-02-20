import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/presentation/providers/event_provider.dart';
import 'package:calendar_craft/presentation/providers/holiday_provider.dart';
import 'package:calendar_craft/presentation/widgets/event_list_widget.dart';
import 'add_event_page.dart';

class DailyAgendaPage extends ConsumerWidget {
  final DateTime date;

  const DailyAgendaPage({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsForDateProvider(date));
    final holidays = ref.watch(holidaysForDateProvider(date));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: (events.isEmpty && holidays.isEmpty)
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate([
                      if (holidays.isNotEmpty) ...[
                        _buildSectionLabel(context, '00 • GLOBAL HOLIDAYS'),
                        const SizedBox(height: 20),
                        ...holidays.map((h) => HolidayCard(holiday: h)),
                        const SizedBox(height: 32),
                      ],
                      if (events.isNotEmpty) ...[
                        _buildSectionLabel(context, '01 • PERSONAL MANIFEST'),
                        const SizedBox(height: 16),
                        ...events.map(
                          (event) => EventCard(
                            event: event,
                            onTap: () => _navigateToEdit(context, event),
                            onEdit: () => _navigateToEdit(context, event),
                            onDelete: () => _deleteEvent(context, ref, event),
                          ),
                        ),
                      ],
                    ]),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEventPage(initialDate: date),
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.add_rounded, size: 36),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: colorScheme.onSurface,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 64, bottom: 20, right: 24),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DATE MANIFEST',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM d, y').format(date),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                fontSize: 22,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 72,
            color: colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'The cosmos is silent.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'The path for this day is yet to be charted. Manifest your next move below.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context, Event event) {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddEventPage(event: event)));
  }

  void _deleteEvent(BuildContext context, WidgetRef ref, Event event) async {
    HapticFeedback.heavyImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Remove "${event.title}" from your manifest?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(eventProvider.notifier).deleteEvent(event.id);
      ref.invalidate(eventsForDateProvider(date));
    }
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.5,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
      ),
    );
  }
}
