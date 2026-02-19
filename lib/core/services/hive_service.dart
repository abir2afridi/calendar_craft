import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../../domain/models/event.dart';
import '../../domain/models/holiday.dart';
import 'hive_adapters.dart';

class HiveService {
  static const String _eventsBoxName = AppConstants.eventsBoxName;
  static const String _holidaysBoxName = AppConstants.holidaysBoxName;
  static const String _settingsBoxName = AppConstants.settingsBoxName;

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Get application documents directory
      // final appDocumentDir = await getApplicationDocumentsDirectory();
      // Hive.initFlutter(appDocumentDir.path);

      // For web, use default path
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(EventAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HolidayAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(EventPriorityAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(EventCategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(RepeatTypeAdapter());
      }

      // Open boxes
      await Hive.openBox<Event>(_eventsBoxName);
      await Hive.openBox<Holiday>(_holidaysBoxName);
      await Hive.openBox(_settingsBoxName);

      _isInitialized = true;
      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Hive: $e');
      rethrow;
    }
  }

  // Event operations
  static Future<void> addEvent(Event event) async {
    try {
      final box = await Hive.openBox<Event>(_eventsBoxName);
      await box.put(event.id, event);
      debugPrint('Event added: ${event.title}');
    } catch (e) {
      debugPrint('Failed to add event: $e');
      rethrow;
    }
  }

  static Future<void> updateEvent(Event event) async {
    try {
      final box = await Hive.openBox<Event>(_eventsBoxName);
      await box.put(event.id, event);
      debugPrint('Event updated: ${event.title}');
    } catch (e) {
      debugPrint('Failed to update event: $e');
      rethrow;
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    try {
      final box = await Hive.openBox<Event>(_eventsBoxName);
      await box.delete(eventId);
      debugPrint('Event deleted: $eventId');
    } catch (e) {
      debugPrint('Failed to delete event: $e');
      rethrow;
    }
  }

  static Future<Event?> getEvent(String eventId) async {
    try {
      final box = await Hive.openBox<Event>(_eventsBoxName);
      return box.get(eventId);
    } catch (e) {
      debugPrint('Failed to get event: $e');
      return null;
    }
  }

  static Future<List<Event>> getAllEvents() async {
    try {
      final box = await Hive.openBox<Event>(_eventsBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('Failed to get all events: $e');
      return [];
    }
  }

  static Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) {
        return event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('Failed to get events for date: $e');
      return [];
    }
  }

  static Future<List<Event>> getEventsForMonth(DateTime month) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) {
        return event.date.year == month.year && event.date.month == month.month;
      }).toList();
    } catch (e) {
      debugPrint('Failed to get events for month: $e');
      return [];
    }
  }

  static Future<List<Event>> searchEvents(String query) async {
    try {
      final allEvents = await getAllEvents();
      final lowerQuery = query.toLowerCase();
      return allEvents.where((event) {
        return event.title.toLowerCase().contains(lowerQuery) ||
            (event.description?.toLowerCase().contains(lowerQuery) ?? false) ||
            (event.location?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      debugPrint('Failed to search events: $e');
      return [];
    }
  }

  static Future<void> clearAllEvents() async {
    try {
      final box = await Hive.openBox<Event>(_eventsBoxName);
      await box.clear();
      debugPrint('All events cleared');
    } catch (e) {
      debugPrint('Failed to clear events: $e');
      rethrow;
    }
  }

  // Holiday operations
  static Future<void> addHoliday(Holiday holiday) async {
    try {
      final box = await Hive.openBox<Holiday>(_holidaysBoxName);
      await box.put(holiday.id, holiday);
      debugPrint('Holiday added: ${holiday.name}');
    } catch (e) {
      debugPrint('Failed to add holiday: $e');
      rethrow;
    }
  }

  static Future<void> addHolidays(List<Holiday> holidays) async {
    try {
      final box = await Hive.openBox<Holiday>(_holidaysBoxName);
      for (final holiday in holidays) {
        await box.put(holiday.id, holiday);
      }
      debugPrint('${holidays.length} holidays added');
    } catch (e) {
      debugPrint('Failed to add holidays: $e');
      rethrow;
    }
  }

  static Future<List<Holiday>> getAllHolidays() async {
    try {
      final box = await Hive.openBox<Holiday>(_holidaysBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('Failed to get all holidays: $e');
      return [];
    }
  }

  static Future<List<Holiday>> getHolidaysForDate(DateTime date) async {
    try {
      final allHolidays = await getAllHolidays();
      return allHolidays.where((holiday) {
        return holiday.date.year == date.year &&
            holiday.date.month == date.month &&
            holiday.date.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('Failed to get holidays for date: $e');
      return [];
    }
  }

  static Future<List<Holiday>> getHolidaysForMonth(DateTime month) async {
    try {
      final allHolidays = await getAllHolidays();
      return allHolidays.where((holiday) {
        return holiday.date.year == month.year &&
            holiday.date.month == month.month;
      }).toList();
    } catch (e) {
      debugPrint('Failed to get holidays for month: $e');
      return [];
    }
  }

  static Future<void> clearAllHolidays() async {
    try {
      final box = await Hive.openBox<Holiday>(_holidaysBoxName);
      await box.clear();
      debugPrint('All holidays cleared');
    } catch (e) {
      debugPrint('Failed to clear holidays: $e');
      rethrow;
    }
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      await box.put(key, value);
      debugPrint('Setting saved: $key');
    } catch (e) {
      debugPrint('Failed to save setting: $e');
      rethrow;
    }
  }

  static Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      return box.get(key, defaultValue: defaultValue);
    } catch (e) {
      debugPrint('Failed to get setting: $e');
      return defaultValue;
    }
  }

  static Future<void> removeSetting(String key) async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      await box.delete(key);
      debugPrint('Setting removed: $key');
    } catch (e) {
      debugPrint('Failed to remove setting: $e');
      rethrow;
    }
  }

  // Backup and restore
  static Future<Map<String, dynamic>> exportData() async {
    try {
      final events = await getAllEvents();
      final holidays = await getAllHolidays();

      return {
        'events': events.map((e) => e.toJson()).toList(),
        'holidays': holidays.map((h) => h.toJson()).toList(),
        'exported_at': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      debugPrint('Failed to export data: $e');
      rethrow;
    }
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data.containsKey('events')) {
        final eventsData = data['events'] as List;
        final events = eventsData.map((e) => Event.fromJson(e)).toList();

        final box = await Hive.openBox<Event>(_eventsBoxName);
        for (final event in events) {
          await box.put(event.id, event);
        }
      }

      if (data.containsKey('holidays')) {
        final holidaysData = data['holidays'] as List;
        final holidays = holidaysData.map((h) => Holiday.fromJson(h)).toList();

        final box = await Hive.openBox<Holiday>(_holidaysBoxName);
        for (final holiday in holidays) {
          await box.put(holiday.id, holiday);
        }
      }

      debugPrint('Data imported successfully');
    } catch (e) {
      debugPrint('Failed to import data: $e');
      rethrow;
    }
  }

  // Cleanup
  static Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
      debugPrint('Hive closed');
    } catch (e) {
      debugPrint('Failed to close Hive: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      await clearAllEvents();
      await clearAllHolidays();

      final settingsBox = await Hive.openBox(_settingsBoxName);
      await settingsBox.clear();

      debugPrint('All data cleared');
    } catch (e) {
      debugPrint('Failed to clear all data: $e');
      rethrow;
    }
  }
}
