class AppConstants {
  // Box names for Hive
  static const String eventsBoxName = 'events_box';
  static const String holidaysBoxName = 'holidays_box';
  static const String settingsBoxName = 'settings_box';

  // App info
  static const String appName = 'Calendar Craft';
  static const String appVersion = '1.0.0';

  // Notification channels
  static const String notificationChannelId = 'calendar_notifications';
  static const String notificationChannelName = 'Calendar Notifications';
  static const String notificationChannelDescription =
      'Notifications for calendar events and reminders';

  // Default values
  static const int defaultReminderMinutes = 15;
  static const String defaultEventColor = '#4CAF50';

  // File names
  static const String backupFileName = 'calendar_backup.json';
  static const String exportFileName = 'calendar_export.json';
  static const String holidaysFileName = 'holidays.json';

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Animation durations
  static const int animationDurationMs = 300;
  static const int longAnimationDurationMs = 500;

  // Grid settings
  static const double defaultCalendarHeight = 400.0;
  static const double eventItemHeight = 60.0;

  // Colors
  static const String primaryColor = '#2196F3';
  static const String secondaryColor = '#FF9800';
  static const String errorColor = '#F44336';
  static const String successColor = '#4CAF50';

  // Limits
  static const int maxEventsPerDay = 50;
  static const int maxReminderCount = 5;
  static const int maxSearchResults = 100;

  // Settings keys
  static const String themeKey = 'theme_mode';
  static const String visualThemeKey = 'visual_theme';
  static const String notificationsKey = 'notifications_enabled';
  static const String defaultReminderKey = 'default_reminder_minutes';
  static const String firstLaunchKey = 'first_launch';
  static const String lastBackupKey = 'last_backup_date';
}
