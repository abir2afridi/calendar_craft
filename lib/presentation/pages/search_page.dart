import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/event_list_widget.dart';
import 'add_event_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  EventCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    if (value.isNotEmpty || _selectedCategory != null) {
      ref.read(eventProvider.notifier).searchEvents(value);
    } else {
      ref.read(eventProvider.notifier).loadEvents();
    }
  }

  void _onCategorySelected(EventCategory? category) {
    HapticFeedback.lightImpact();
    setState(() => _selectedCategory = category);
    ref.read(eventProvider.notifier).searchEvents(_query);
  }

  @override
  Widget build(BuildContext context) {
    var results = ref.watch(eventProvider).events;
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedCategory != null) {
      results = results.where((e) => e.category == _selectedCategory).toList();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context),
            _buildQuickFilters(context),
            Expanded(
              child: _query.isEmpty && _selectedCategory == null
                  ? EventListWidget(
                      events: results,
                      onEventTap: (event) => _navigateToEdit(context, event),
                      onEventEdit: (event) => _navigateToEdit(context, event),
                      onEventDelete: (event) => _deleteEvent(context, event),
                    )
                  : results.isEmpty
                  ? _buildEmptyState(context)
                  : EventListWidget(
                      events: results,
                      onEventTap: (event) => _navigateToEdit(context, event),
                      onEventEdit: (event) => _navigateToEdit(context, event),
                      onEventDelete: (event) => _deleteEvent(context, event),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UNIVERSE SEARCH',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Craft Your Search',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  fontSize: 32,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'Search the manifest...',
                hintStyle: TextStyle(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 24,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _searchController.clear();
                          _onQueryChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onQueryChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.only(bottom: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _filterChip(
            context,
            'ALL',
            Icons.grid_view_rounded,
            _selectedCategory == null,
            null,
          ),
          ...EventCategory.values.map(
            (cat) => _filterChip(
              context,
              cat.displayName.toUpperCase(),
              _getCategoryIcon(cat),
              _selectedCategory == cat,
              cat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    EventCategory? category,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _onCategorySelected(category),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? colorScheme.surface
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.surface
                      : colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.02),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.blur_on_rounded,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'The cosmos is empty.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Adjust your manifest search to find what you seek.',
            style: TextStyle(
              color: colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Event event) {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddEventPage(event: event)));
  }

  void _deleteEvent(BuildContext context, Event event) async {
    HapticFeedback.heavyImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Remove "${event.title}" forever?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
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
    }
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.personal:
        return Icons.person_rounded;
      case EventCategory.work:
        return Icons.work_rounded;
      case EventCategory.health:
        return Icons.favorite_rounded;
      case EventCategory.education:
        return Icons.school_rounded;
      case EventCategory.entertainment:
        return Icons.movie_rounded;
      case EventCategory.social:
        return Icons.group_rounded;
      case EventCategory.travel:
        return Icons.flight_rounded;
      case EventCategory.birthday:
        return Icons.cake_rounded;
      case EventCategory.other:
        return Icons.category_rounded;
    }
  }
}
