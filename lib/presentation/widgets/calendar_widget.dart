import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/presentation/providers/event_provider.dart';
import 'package:calendar_craft/presentation/providers/theme_provider.dart';
import 'package:calendar_craft/presentation/providers/holiday_provider.dart';
import 'package:calendar_craft/domain/models/holiday.dart';
import 'package:intl/intl.dart';

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
    final events = ref.watch(eventsForMonthProvider(focusedDay));
    final holidayState = ref.watch(holidayProvider);
    final holidays = ref.watch(holidaysForMonthProvider(focusedDay));
    final visualTheme = ref.watch(visualThemeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: _buildCalendar(
              context,
              events,
              holidays,
              holidayState.countryName,
              visualTheme,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<Event> events,
    List<Holiday> holidays,
    String? countryName,
    VisualTheme style,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: calendarFormat,
      eventLoader: (day) {
        final dayEvents = events.where((e) => isSameDay(e.date, day)).toList();
        final dayHolidays = holidays
            .where((h) => isSameDay(h.date, day))
            .toList();
        return [...dayEvents, ...dayHolidays];
      },
      onDaySelected: (selectedDay, focusedDay) {
        HapticFeedback.lightImpact();
        onDaySelected(selectedDay, focusedDay);
      },
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: 52,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: true,
        formatButtonShowsNext: false,
        leftChevronIcon: _buildChevron(context, Icons.chevron_left_rounded),
        rightChevronIcon: _buildChevron(context, Icons.chevron_right_rounded),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        formatButtonDecoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        formatButtonTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: colorScheme.outline.withValues(alpha: 0.5),
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
        weekendStyle: TextStyle(
          color: Colors.redAccent.withValues(alpha: 0.4),
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        todayDecoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        todayTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
        selectedDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        markerDecoration: const BoxDecoration(color: Colors.transparent),
        defaultTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        weekendTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.redAccent,
        ),
        outsideTextStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.2),
          fontWeight: FontWeight.w500,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, date) {
          final monthYear = DateFormat.yMMMM().format(date);
          return Column(
            children: [
              Text(
                monthYear.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: colorScheme.onSurface,
                ),
              ),
              if (countryName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    countryName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
            ],
          );
        },
        markerBuilder: (context, date, items) {
          if (items.isEmpty) return null;

          final dayEvents = items.whereType<Event>().toList();
          final dayHolidays = items.whereType<Holiday>().toList();

          return Positioned(
            bottom: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dayHolidays.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ...dayEvents
                    .take(2)
                    .map(
                      (event) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: event.uiColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChevron(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.04),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Icon(icon, color: colorScheme.onSurface, size: 18),
    );
  }
}
