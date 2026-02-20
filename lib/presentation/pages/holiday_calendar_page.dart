import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/holiday_provider.dart';
import '../../domain/models/holiday.dart';
import '../widgets/event_list_widget.dart'; // Reuse HolidayCard

class HolidayCalendarPage extends ConsumerStatefulWidget {
  const HolidayCalendarPage({super.key});

  @override
  ConsumerState<HolidayCalendarPage> createState() =>
      _HolidayCalendarPageState();
}

class _HolidayCalendarPageState extends ConsumerState<HolidayCalendarPage> {
  @override
  void initState() {
    super.initState();
    // Refresh holidays on entry
    Future.microtask(() => ref.read(holidayProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final holidayState = ref.watch(holidayProvider);
    final upcomingHolidays = _getGroupedHolidays(holidayState.holidays);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, holidayState),
          if (holidayState.isLoading && holidayState.holidays.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (holidayState.holidays.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context, holidayState))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final monthKey = upcomingHolidays.keys.elementAt(index);
                  final monthHolidays = upcomingHolidays[monthKey]!;
                  return _buildMonthSection(context, monthKey, monthHolidays);
                }, childCount: upcomingHolidays.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, HolidayState state) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        IconButton(
          onPressed: () => ref.read(holidayProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.countryName?.toUpperCase() ?? 'GLOBAL MANIFEST',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Text(
              'Holiday Calendar',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ],
        ),
        background: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Icons.public_rounded,
                  size: 200,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSection(
    BuildContext context,
    String monthYear,
    List<Holiday> holidays,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
            children: [
              Text(
                monthYear.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ],
          ),
        ),
        ...holidays.map((h) => HolidayCard(holiday: h)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, HolidayState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Holidays Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'We couldn\'t find any holiday manifests for ${state.countryName ?? "your region"}.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => ref.read(holidayProvider.notifier).refresh(),
            icon: const Icon(Icons.location_searching_rounded),
            label: const Text('DETECT LOCATION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              foregroundColor: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Holiday>> _getGroupedHolidays(List<Holiday> holidays) {
    final sorted = List<Holiday>.from(holidays)
      ..sort((a, b) => a.date.compareTo(b.date));

    final Map<String, List<Holiday>> grouped = {};
    for (var h in sorted) {
      final month = DateFormat.yMMMM().format(h.date);
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(h);
    }
    return grouped;
  }
}
