import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/presentation/providers/event_provider.dart';
import 'package:calendar_craft/presentation/widgets/event_list_widget.dart';
import 'package:calendar_craft/presentation/providers/theme_provider.dart';
import 'add_event_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visualTheme = ref.watch(visualThemeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: theme.textTheme.titleMedium?.copyWith(
            color: visualTheme == VisualTheme.cyber ? theme.primaryColor : null,
          ),
          decoration: InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
            if (value.isNotEmpty) {
              ref.read(eventProvider.notifier).searchEvents(value);
            }
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                });
                ref.read(eventProvider.notifier).loadEvents();
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _buildInitialState()
          : ref.watch(eventProvider).isLoading
          ? const Center(child: CircularProgressIndicator())
          : EventListWidget(
              events: ref.watch(eventProvider).events,
              onEventTap: (event) => _navigateToEdit(context, event),
              onEventEdit: (event) => _navigateToEdit(context, event),
              onEventDelete: (event) => _deleteEvent(context, event),
            ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'Find your moments',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[500]),
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

  void _deleteEvent(BuildContext context, Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event deleted')));
      }
    }
  }
}
