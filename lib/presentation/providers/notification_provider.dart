import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/notification_service.dart';

class NotificationSettings {
  final bool enabled;
  final bool eventReminders;
  final bool dailySummary;
  final int defaultReminderMinutes;

  NotificationSettings({
    this.enabled = true,
    this.eventReminders = true,
    this.dailySummary = false,
    this.defaultReminderMinutes = 10,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? eventReminders,
    bool? dailySummary,
    int? defaultReminderMinutes,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      eventReminders: eventReminders ?? this.eventReminders,
      dailySummary: dailySummary ?? this.dailySummary,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'eventReminders': eventReminders,
    'dailySummary': dailySummary,
    'defaultReminderMinutes': defaultReminderMinutes,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        enabled: json['enabled'] ?? true,
        eventReminders: json['eventReminders'] ?? true,
        dailySummary: json['dailySummary'] ?? false,
        defaultReminderMinutes: json['defaultReminderMinutes'] ?? 10,
      );
}

class NotificationNotifier extends StateNotifier<NotificationSettings> {
  NotificationNotifier() : super(NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final json = await HiveService.getSetting<Map>('notification_settings');
    if (json != null) {
      state = NotificationSettings.fromJson(Map<String, dynamic>.from(json));
      if (state.enabled && state.dailySummary) {
        NotificationService().scheduleGreetingNotifications();
      }
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    state = settings;
    await HiveService.saveSetting('notification_settings', settings.toJson());

    if (!settings.enabled) {
      await NotificationService().cancelAllNotifications();
    } else if (settings.dailySummary) {
      await NotificationService().scheduleGreetingNotifications();
    }
  }

  Future<void> toggleEnabled() async {
    await updateSettings(state.copyWith(enabled: !state.enabled));
  }

  Future<void> toggleEventReminders() async {
    await updateSettings(state.copyWith(eventReminders: !state.eventReminders));
  }

  Future<void> toggleDailySummary() async {
    await updateSettings(state.copyWith(dailySummary: !state.dailySummary));
  }

  Future<void> setDefaultReminder(int minutes) async {
    await updateSettings(state.copyWith(defaultReminderMinutes: minutes));
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationSettings>((ref) {
      return NotificationNotifier();
    });
