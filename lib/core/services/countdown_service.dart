import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event.dart';
import '../../presentation/providers/event_provider.dart';
import 'notification_service.dart';

class CountdownService {
  Timer? _tickTimer;
  Timer? _notificationTimer;
  final Ref _ref;

  CountdownService(this._ref);

  void startTimers() {
    // 1. Precise tick for UI (seconds)
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // StreamProvider tickProvider handles this reactive update
    });

    // 2. Efficient update for notifications (every hour)
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _updateAllEventNotifications();
    });
  }

  void _updateAllEventNotifications() {
    final events = _ref.read(eventProvider).events;
    NotificationService().refreshCountdownNotifications(events);
  }

  void dispose() {
    _tickTimer?.cancel();
    _notificationTimer?.cancel();
  }
}

// Emits the current time every second for reactive UI
final tickProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// Provides calculated duration for a specific event
final eventCountdownProvider = Provider.family<Duration, Event>((ref, event) {
  final now = ref.watch(tickProvider).value ?? DateTime.now();
  if (event.isAllDay) {
    final eventDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );
    return eventDate.difference(DateTime(now.year, now.month, now.day));
  }
  final target = event.startTime ?? event.date;
  return target.difference(now);
});

// Global countdown service provider
final countdownServiceProvider = Provider((ref) {
  final service = CountdownService(ref);
  service.startTimers();
  ref.onDispose(() => service.dispose());
  return service;
});
