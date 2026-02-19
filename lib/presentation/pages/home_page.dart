import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/event_list_widget.dart';
import '../widgets/floating_action_button_widget.dart';
import '../providers/event_provider.dart';
import '../providers/theme_provider.dart';
import 'add_event_page.dart';
import 'settings_page.dart';
import 'search_page.dart';
import 'daily_agenda_page.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visualTheme = ref.watch(visualThemeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Craft'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
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
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (CalendarFormat format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Events',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: visualTheme == VisualTheme.cyber
                        ? 'Orbitron'
                        : null,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            DailyAgendaPage(date: _selectedDay),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_view_day),
                  label: const Text('View Agenda'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: EventListWidget(
              events: ref
                  .watch(eventProvider)
                  .events
                  .where((e) => isSameDay(e.date, _selectedDay))
                  .toList(),
              onEventTap: (event) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(event: event),
                  ),
                );
              },
              onEventEdit: (event) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(event: event),
                  ),
                );
              },
              onEventDelete: (event) async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Event'),
                    content: const Text(
                      'Are you sure you want to delete this event?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(eventProvider.notifier).deleteEvent(event.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event deleted')),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonWidget(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AddEventPage(event: null, initialDate: _selectedDay),
            ),
          );
        },
      ),
    );
  }
}
