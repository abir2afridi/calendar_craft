import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/presentation/providers/theme_provider.dart';

class EventListWidget extends ConsumerWidget {
  final List<Event> events;
  final Function(Event) onEventTap;
  final Function(Event) onEventEdit;
  final Function(Event) onEventDelete;

  const EventListWidget({
    super.key,
    required this.events,
    required this.onEventTap,
    required this.onEventEdit,
    required this.onEventDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualTheme = ref.watch(visualThemeProvider);

    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          style: visualTheme,
          onTap: () => onEventTap(event),
          onEdit: () => onEventEdit(event),
          onDelete: () => onEventDelete(event),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VisualTheme style;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.style,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final eventColor = event.uiColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: style == VisualTheme.cyber
          ? BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: eventColor.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(color: eventColor.withOpacity(0.2), blurRadius: 4),
              ],
            )
          : style == VisualTheme.bento
          ? BoxDecoration(
              color: eventColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            )
          : null, // Card parent handled by theme
      child: Card(
        // For classic style, theme's CardTheme applies.
        // For bento/cyber, we might want to override or simplify.
        elevation: style == VisualTheme.monthly ? null : 0,
        color: style == VisualTheme.monthly ? null : Colors.transparent,
        margin: EdgeInsets.zero,
        shape: style == VisualTheme.bento
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
            : style == VisualTheme.cyber
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
            : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            style == VisualTheme.bento
                ? 24
                : (style == VisualTheme.cyber ? 4 : 12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: style == VisualTheme.bento ? 12 : 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: eventColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: style == VisualTheme.cyber ? 18 : 16,
                              letterSpacing: style == VisualTheme.cyber
                                  ? 1
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.timeDisplay,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showMenu(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Event'),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Event',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
