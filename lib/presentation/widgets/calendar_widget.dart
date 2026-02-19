import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_craft/presentation/providers/event_provider.dart';

class CalendarWidget extends ConsumerWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsForMonth = ref.watch(eventsForMonthProvider(focusedDay));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: eventsForMonth.when(
          data: (events) => _buildCalendar(context, events),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading calendar: $error')),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, List events) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      calendarFormat: calendarFormat,
      eventLoader: (day) {
        return events.where((event) {
          return isSameDay(event.date, day);
        }).toList();
      },
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        formatButtonTextStyle: TextStyle(color: Colors.white),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        weekendTextStyle: const TextStyle(color: Colors.red),
        holidayTextStyle: const TextStyle(color: Colors.red),
        todayDecoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        canMarkersOverflow: true,
        markersAnchor: 0.7,
        markersAlignment: Alignment.bottomCenter,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox();

          return Positioned(bottom: 1, child: _buildMarkers(events.length));
        },
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(context, day, focusedDay, false);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(context, day, focusedDay, true);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(context, day, focusedDay, false, isToday: true);
        },
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
    bool isSelected, {
    bool isToday = false,
  }) {
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? Theme.of(context).primaryColor
            : isToday
            ? Theme.of(context).primaryColor.withOpacity(0.3)
            : null,
        border: isToday && !isSelected
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isWeekend
                ? Colors.red
                : isToday
                ? Theme.of(context).primaryColor
                : null,
            fontWeight: isToday || isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMarkers(int eventCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        eventCount.clamp(0, 3),
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _getEventColor(index),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Color _getEventColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
