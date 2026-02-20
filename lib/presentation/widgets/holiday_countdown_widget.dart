import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/holiday_provider.dart';

class HolidayCountdownWidget extends ConsumerWidget {
  const HolidayCountdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidayState = ref.watch(holidayProvider);
    final holidays = holidayState.holidays;
    final colorScheme = Theme.of(context).colorScheme;

    if (holidays.isEmpty) return const SizedBox.shrink();

    // Find the nearest upcoming holiday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcomingHolidays =
        holidays
            .where(
              (h) => h.date.isAtSameMomentAs(today) || h.date.isAfter(today),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (upcomingHolidays.isEmpty) return const SizedBox.shrink();

    final nextHoliday = upcomingHolidays.first;
    final daysUntil = nextHoliday.date.difference(today).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Colors.redAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT GLOBAL HOLIDAY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nextHoliday.name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  daysUntil == 0
                      ? 'MANIFESTING TODAY'
                      : '$daysUntil ${daysUntil == 1 ? 'DAY' : 'DAYS'} REMAINING',
                  style: TextStyle(
                    color: daysUntil == 0
                        ? Colors.redAccent
                        : colorScheme.outline,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          _buildDatePill(nextHoliday.date, colorScheme),
        ],
      ),
    );
  }

  Widget _buildDatePill(DateTime date, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            DateFormat('dd').format(date),
            style: TextStyle(
              color: colorScheme.surface,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              color: colorScheme.surface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
