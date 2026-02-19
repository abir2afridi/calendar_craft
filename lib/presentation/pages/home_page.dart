import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_craft/presentation/providers/event_provider.dart';
import 'package:calendar_craft/presentation/widgets/calendar_widget.dart';
import 'package:calendar_craft/presentation/widgets/event_list_widget.dart';
import 'package:calendar_craft/presentation/widgets/floating_action_button_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Load events when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsForDateProvider(_selectedDay));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Craft'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarWidget(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return _buildEmptyState();
                }
                return EventListWidget(
                  events: events,
                  onEventTap: (event) => _showEventDetails(context, event),
                  onEventEdit: (event) => _editEvent(context, event),
                  onEventDelete: (event) => _deleteEvent(context, event),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error loading events: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonWidget(
        onPressed: () => _addEvent(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events for this day',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add an event',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Events'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter event title or description...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(eventProvider.notifier).searchEvents(controller.text);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Navigate to settings page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings page coming soon!')));
  }

  void _addEvent(BuildContext context) {
    // TODO: Navigate to add/edit event page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add event page coming soon!')),
    );
  }

  void _showEventDetails(BuildContext context, event) {
    // TODO: Show event details
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Event details for ${event.title}')));
  }

  void _editEvent(BuildContext context, event) {
    // TODO: Navigate to edit event page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${event.title}')));
  }

  void _deleteEvent(BuildContext context, event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(eventProvider.notifier).deleteEvent(event.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Event deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
