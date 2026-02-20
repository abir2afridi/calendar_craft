import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event.dart';
import 'event_provider.dart';

final upcomingEventProvider = Provider<Event?>((ref) {
  final events = ref.watch(eventProvider).events;
  final now = DateTime.now();

  // Filter for future events and sort by date
  final futureEvents =
      events.where((e) {
        if (e.isCompleted) return false;
        final target = e.startTime ?? e.date;
        return target.isAfter(now);
      }).toList()..sort(
        (a, b) => (a.startTime ?? a.date).compareTo(b.startTime ?? b.date),
      );

  return futureEvents.isEmpty ? null : futureEvents.first;
});
