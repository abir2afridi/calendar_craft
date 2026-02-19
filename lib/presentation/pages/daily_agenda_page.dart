import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/presentation/providers/event_provider.dart';
import 'package:calendar_craft/presentation/providers/theme_provider.dart';
import 'package:calendar_craft/presentation/widgets/event_list_widget.dart';
import 'add_event_page.dart';

class DailyAgendaPage extends ConsumerWidget {
  final DateTime date;

  const DailyAgendaPage({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsForDateProvider(date));
    final visualTheme = ref.watch(visualThemeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: visualTheme == VisualTheme.bento
          ? (isDark ? Colors.black : const Color(0xFFF5F5F7))
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontFamily: visualTheme == VisualTheme.cyber
                        ? 'Orbitron'
                        : null,
                  ),
                ),
                Text(
                  DateFormat('EEEE, d').format(date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: visualTheme == VisualTheme.cyber
                        ? 'Orbitron'
                        : null,
                    color: visualTheme == VisualTheme.cyber
                        ? theme.primaryColor
                        : null,
                    letterSpacing: visualTheme == VisualTheme.cyber
                        ? 1.5
                        : null,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEventPage(initialDate: date),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverFillRemaining(
            child: eventsAsync.when(
              data: (events) => events.isEmpty
                  ? _buildEmptyState(context, visualTheme)
                  : EventListWidget(
                      events: events,
                      onEventTap: (event) => _navigateToEdit(context, event),
                      onEventEdit: (event) => _navigateToEdit(context, event),
                      onEventDelete: (event) =>
                          _deleteEvent(context, ref, event),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, VisualTheme style) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing planned yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontFamily: style == VisualTheme.cyber ? 'Orbitron' : null,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEventPage(initialDate: date),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Event'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  style == VisualTheme.bento
                      ? 24
                      : (style == VisualTheme.cyber ? 4 : 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Event event) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddEventPage(event: event)));
  }

  void _deleteEvent(BuildContext context, WidgetRef ref, Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(eventProvider.notifier).deleteEvent(event.id);
      // We might need to refresh the future provider or rely on the stream/state
      // Since eventsForDateProvider is a FutureProvider, it won't automatically refresh
      // unless we invalidate it.
      ref.invalidate(eventsForDateProvider(date));
    }
  }
}
