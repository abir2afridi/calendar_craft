import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:calendar_craft/domain/models/event.dart';
import 'package:calendar_craft/core/services/hive_service.dart';
import 'package:calendar_craft/core/services/notification_service.dart';
import 'package:calendar_craft/core/services/firestore_service.dart';
import 'package:calendar_craft/core/services/countdown_service.dart';
import 'package:calendar_craft/presentation/providers/auth_provider.dart';

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

  List<Event> get activeEvents => events.where((e) => !e.isCompleted).toList();
  List<Event> get completedEvents =>
      events.where((e) => e.isCompleted).toList();

  bool get hasUnsyncedEvents => events.any((e) => e.isSyncPending);
}

class EventNotifier extends StateNotifier<EventState> {
  final FirestoreService _firestoreService = FirestoreService();
  final Ref _ref;

  EventNotifier(this._ref) : super(const EventState()) {
    _initTickListener();
    _initAuthListener();
  }

  void _initAuthListener() {
    // Listen for auth state changes to trigger re-sync
    _ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        debugPrint(
          '👤 EventNotifier: User logged in (${next.value!.uid}). Checking manifest...',
        );
        loadEvents();
      }
    });
  }

  void _initTickListener() {
    _ref.listen<AsyncValue<DateTime>>(tickProvider, (previous, next) {
      if (next is AsyncData) {
        _checkEventCompletion(next.value!);
      }
    });
  }

  void _checkEventCompletion(DateTime now) {
    bool stateChanged = false;
    final updatedEvents = state.events.map((event) {
      if (!event.isCompleted) {
        final target = event.endTime ?? event.startTime ?? event.date;
        if (now.isAfter(target)) {
          stateChanged = true;
          final completedEvent = event.copyWith(isCompleted: true);
          HiveService.updateEvent(completedEvent);
          return completedEvent;
        }
      }
      return event;
    }).toList();

    if (stateChanged) {
      state = state.copyWith(events: updatedEvents);
    }
  }

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

      // Pull cloud events automatically, but don't push local ones yet
      _syncFromCloud();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Explicitly backup local guest events to the logged-in account
  Future<void> syncLocalToCloud() async {
    try {
      final uid = _firestoreService.uid;
      if (uid == null) throw Exception('Authentication required for backup');

      state = state.copyWith(isLoading: true);
      debugPrint('☁️ Backup: Migrating local manifest to cloud...');

      // Filter only unsynced events
      final unsynced = state.events.where((e) => e.isSyncPending).toList();

      if (unsynced.isEmpty) {
        debugPrint('☁️ Backup: No local events need syncing.');
        state = state.copyWith(isLoading: false);
        return;
      }

      await _firestoreService.syncLocalWithCloud(unsynced);

      // Update local Hive records to mark them as synced
      for (final event in unsynced) {
        final syncedEvent = event.copyWith(isSyncPending: false);
        await HiveService.updateEvent(syncedEvent);
      }

      // Update local state to reflect sync completion
      final allEvents = await HiveService.getAllEvents();
      allEvents.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        final aTime = a.startTime ?? a.date;
        final bTime = b.startTime ?? b.date;
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(events: allEvents, isLoading: false);
      debugPrint(
        '✅ Backup: Migration complete. ${unsynced.length} events saved.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Backup failed: $e');
      debugPrint('🚨 Backup Error: $e');
    }
  }

  Future<void> _syncFromCloud() async {
    try {
      final uid = _firestoreService.uid;
      if (uid == null) {
        debugPrint('☁️ Sync: User not logged in, skipping cloud pull.');
        return;
      }

      // 1. Pull cloud events to local
      debugPrint('☁️ Sync: Fetching cloud events...');
      final cloudEvents = await _firestoreService.getEvents();

      if (cloudEvents.isNotEmpty) {
        bool localChanged = false;
        final localIds = state.events.map((e) => e.id).toSet();

        for (final cloudEvent in cloudEvents) {
          if (!localIds.contains(cloudEvent.id)) {
            debugPrint('☁️ Sync: Integrating cloud event: ${cloudEvent.title}');
            // Cloud events are by definition already synced
            await HiveService.addEvent(
              cloudEvent.copyWith(isSyncPending: false),
            );
            localChanged = true;
          }
        }

        if (localChanged) {
          final updatedEvents = await HiveService.getAllEvents();
          updatedEvents.sort((a, b) {
            final dateCompare = a.date.compareTo(b.date);
            if (dateCompare != 0) return dateCompare;
            final aTime = a.startTime ?? a.date;
            final bTime = b.startTime ?? b.date;
            return aTime.compareTo(bTime);
          });
          state = state.copyWith(events: updatedEvents);
          debugPrint('☁️ Sync: Local state updated with cloud legacy');
        } else {
          debugPrint('☁️ Sync: Local manifest is up to date');
        }
      }

      debugPrint('☁️ Sync: Completed successfully');
    } catch (e) {
      debugPrint('☁️ Sync Error: $e');
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await HiveService.addEvent(event);
      await _firestoreService.saveEvent(event);

      // Update local to synced if save succeeded
      final syncedEvent = event.copyWith(isSyncPending: false);
      await HiveService.updateEvent(syncedEvent);

      await NotificationService().scheduleEventNotification(syncedEvent);

      final updatedEvents = [
        ...state.events.where((e) => e.id != event.id),
        syncedEvent,
      ];
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

      // Update local to synced
      final syncedEvent = event.copyWith(isSyncPending: false);
      await HiveService.updateEvent(syncedEvent);

      await NotificationService().scheduleEventNotification(syncedEvent);

      final updatedEvents = state.events
          .map((e) => e.id == event.id ? syncedEvent : e)
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
  return EventNotifier(ref);
});

final eventsForDateProvider = Provider.family<List<Event>, DateTime>((
  ref,
  date,
) {
  final allEvents = ref.watch(eventProvider).events;
  return allEvents
      .where(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
      )
      .toList();
});

final eventsForMonthProvider = Provider.family<List<Event>, DateTime>((
  ref,
  month,
) {
  final allEvents = ref.watch(eventProvider).events;
  return allEvents
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();
});

final searchResultsProvider = FutureProvider.family<List<Event>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  return await HiveService.searchEvents(query);
});
