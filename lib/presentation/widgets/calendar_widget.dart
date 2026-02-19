import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/presentation/providers/event_provider.dart';
import 'package:calendar_craft/presentation/providers/theme_provider.dart';

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
    final visualTheme = ref.watch(visualThemeProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: eventsForMonth.when(
          data: (events) => _buildCalendar(context, events, visualTheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading calendar: $error')),
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<Event> events,
    VisualTheme style,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: calendarFormat,
      eventLoader: (day) =>
          events.where((e) => isSameDay(e.date, day)).toList(),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      headerStyle: HeaderStyle(
        formatButtonVisible: style != VisualTheme.cyber,
        titleCentered: true,
        formatButtonShowsNext: false,
        titleTextStyle: TextStyle(
          fontSize: style == VisualTheme.cyber ? 22 : 18,
          fontWeight: FontWeight.bold,
          color: style == VisualTheme.cyber ? primaryColor : null,
          letterSpacing: style == VisualTheme.cyber ? 2 : null,
        ),
        formatButtonDecoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(
            style == VisualTheme.bento ? 20 : 8,
          ),
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3),
          shape: style == VisualTheme.cyber
              ? BoxShape.rectangle
              : BoxShape.circle,
          borderRadius: style == VisualTheme.cyber
              ? BorderRadius.circular(4)
              : null,
        ),
        selectedDecoration: BoxDecoration(
          color: primaryColor,
          shape: style == VisualTheme.cyber
              ? BoxShape.rectangle
              : BoxShape.circle,
          borderRadius: style == VisualTheme.cyber
              ? BorderRadius.circular(4)
              : null,
          boxShadow: style == VisualTheme.cyber
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.6),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        markerDecoration: BoxDecoration(
          color: style == VisualTheme.cyber ? Colors.white : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox();
          return Positioned(
            bottom: 4,
            child: _buildMarkers(events.length, style),
          );
        },
        defaultBuilder: (context, day, focusedDay) =>
            _buildDayCell(context, day, focusedDay, false, style),
        selectedBuilder: (context, day, focusedDay) =>
            _buildDayCell(context, day, focusedDay, true, style),
        todayBuilder: (context, day, focusedDay) => _buildDayCell(
          context,
          day,
          focusedDay,
          false,
          style,
          isToday: true,
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
    bool isSelected,
    VisualTheme style, {
    bool isToday = false,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final isWeekend = day.weekday == 6 || day.weekday == 7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      decoration: style == VisualTheme.cyber
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isSelected ? primaryColor : null,
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : isToday
                    ? primaryColor.withOpacity(0.5)
                    : Colors.transparent,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            )
          : BoxDecoration(
              shape: style == VisualTheme.bento
                  ? BoxShape.rectangle
                  : BoxShape.circle,
              borderRadius: style == VisualTheme.bento
                  ? BorderRadius.circular(12)
                  : null,
              color: isSelected
                  ? primaryColor
                  : isToday
                  ? primaryColor.withOpacity(0.2)
                  : null,
            ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isWeekend
                ? (style == VisualTheme.cyber ? Colors.pinkAccent : Colors.red)
                : null,
            fontWeight: isSelected || isToday
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: style == VisualTheme.cyber ? 16 : 14,
            shadows: isSelected && style == VisualTheme.cyber
                ? [const Shadow(color: Colors.white, blurRadius: 8)]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildMarkers(int eventCount, VisualTheme style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        eventCount.clamp(0, 3),
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: style == VisualTheme.cyber ? 4 : 6,
          height: style == VisualTheme.cyber ? 4 : 6,
          decoration: BoxDecoration(
            color: style == VisualTheme.cyber
                ? const Color(0xFF00F2FF)
                : _getEventColor(index),
            shape: BoxShape.circle,
            boxShadow: style == VisualTheme.cyber
                ? [const BoxShadow(color: Color(0xFF00F2FF), blurRadius: 4)]
                : null,
          ),
        ),
      ),
    );
  }

  Color _getEventColor(int index) {
    const colors = [
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
