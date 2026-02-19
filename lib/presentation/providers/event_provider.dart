import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/core/services/hive_service.dart';
import 'package:calendar_craft/core/services/notification_service.dart';
import 'package:calendar_craft/core/services/firestore_service.dart';

class EventState {
  final List<Event> events;
  final bool isLoading;
  final String? error;

  const EventState({
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  EventState copyWith({List<Event>? events, bool? isLoading, String? error}) {
    return EventState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class EventNotifier extends StateNotifier<EventState> {
  final _firestoreService = FirestoreService();

  EventNotifier() : super(const EventState());

  Future<void> loadEvents() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final events = await HiveService.getAllEvents();

      // Sort events by date and time
      events.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;

        final aTime = a.startTime ?? a.date;
        final bTime = b.startTime ?? b.date;
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(events: events, isLoading: false);

      // Try to sync with cloud in background
      _syncFromCloud();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _syncFromCloud() async {
    try {
      final cloudEvents = await _firestoreService.getEvents();
      if (cloudEvents.isNotEmpty) {
        // Simple merge logic: if cloud has events not in local, add them
        final localIds = state.events.map((e) => e.id).toSet();
        for (final cloudEvent in cloudEvents) {
          if (!localIds.contains(cloudEvent.id)) {
            await HiveService.addEvent(cloudEvent);
          }
        }
        // Reload local events after sync
        final updatedEvents = await HiveService.getAllEvents();
        updatedEvents.sort((a, b) {
          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;
          final aTime = a.startTime ?? a.date;
          final bTime = b.startTime ?? b.date;
          return aTime.compareTo(bTime);
        });
        state = state.copyWith(events: updatedEvents);
      }
    } catch (e) {
      print('Background sync error: $e');
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await HiveService.addEvent(event);
      await _firestoreService.saveEvent(event);
      await NotificationService().scheduleEventNotification(event);

      final updatedEvents = [...state.events, event];
      updatedEvents.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;

        final aTime = a.startTime ?? a.date;
        final bTime = b.startTime ?? b.date;
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(events: updatedEvents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await HiveService.updateEvent(event);
      await _firestoreService.saveEvent(event);
      await NotificationService().scheduleEventNotification(event);

      final updatedEvents = state.events
          .map((e) => e.id == event.id ? event : e)
          .toList();
      updatedEvents.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;

        final aTime = a.startTime ?? a.date;
        final bTime = b.startTime ?? b.date;
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(events: updatedEvents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await NotificationService().cancelEventNotifications(eventId);
      await HiveService.deleteEvent(eventId);
      await _firestoreService.deleteEvent(eventId);

      final updatedEvents = state.events.where((e) => e.id != eventId).toList();

      state = state.copyWith(events: updatedEvents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      await loadEvents();
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final searchResults = await HiveService.searchEvents(query);

      state = state.copyWith(events: searchResults, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      return await HiveService.getEventsForDate(date);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<List<Event>> getEventsForMonth(DateTime month) async {
    try {
      return await HiveService.getEventsForMonth(month);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await loadEvents();
  }
}

// Providers
final eventProvider = StateNotifierProvider<EventNotifier, EventState>((ref) {
  return EventNotifier();
});

final eventsForDateProvider = FutureProvider.family<List<Event>, DateTime>((
  ref,
  date,
) async {
  return await HiveService.getEventsForDate(date);
});

final eventsForMonthProvider = FutureProvider.family<List<Event>, DateTime>((
  ref,
  month,
) async {
  return await HiveService.getEventsForMonth(month);
});

final searchResultsProvider = FutureProvider.family<List<Event>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  return await HiveService.searchEvents(query);
});
