import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../constants/app_constants.dart';
import '../../domain/models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      const AndroidNotificationChannel androidChannel =
          AndroidNotificationChannel(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            description: AppConstants.notificationChannelDescription,
            importance: Importance.high,
          );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      _isInitialized = true;
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission = await androidImplementation
          ?.requestNotificationsPermission();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return grantedNotificationPermission ?? false;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }

  Future<void> scheduleEventNotification(Event event) async {
    if (!_isInitialized) await init();

    try {
      // Cancel existing notifications for this event
      await cancelEventNotifications(event.id);

      // Schedule new notifications for each reminder time
      for (final reminderTime in event.reminderTimes) {
        await _scheduleSingleNotification(event, reminderTime);
      }

      debugPrint(
        'Scheduled ${event.reminderTimes.length} notifications for event: ${event.title}',
      );
    } catch (e) {
      debugPrint('Failed to schedule event notification: $e');
    }
  }

  Future<void> refreshCountdownNotifications(List<Event> events) async {
    final now = DateTime.now();
    for (final event in events) {
      if (event.isCompleted) continue;

      final target = event.startTime ?? event.date;
      if (target.isAfter(now)) {
        // Refresh only the next relevant reminder
        await scheduleEventNotification(event);
      }
    }
  }

  Future<void> _scheduleSingleNotification(
    Event event,
    DateTime reminderTime,
  ) async {
    try {
      final scheduledTime = reminderTime.isBefore(DateTime.now())
          ? DateTime.now().add(
              const Duration(seconds: 5),
            ) // Schedule for 5 seconds from now if time is in the past
          : reminderTime;

      final remainingDays = event.date.difference(DateTime.now()).inDays;
      final countdownTitle = remainingDays > 0
          ? '[$remainingDays days left] ${event.title}'
          : 'Event Reminder: ${event.title}';

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _generateNotificationId(event.id, reminderTime),
        countdownTitle,
        _buildNotificationBody(event),
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF2196F3),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: event.id,
      );
    } catch (e) {
      debugPrint('Failed to schedule single notification: $e');
    }
  }

  Future<void> scheduleGreetingNotifications() async {
    if (!_isInitialized) await init();

    try {
      // IDs for greetings: Morning: 1001, Afternoon: 1002, Evening: 1003, Night: 1004

      // Good Morning: 5:00 AM
      await _scheduleDailyNotification(
        1001,
        '🌅 Good Morning',
        'Start your day with purpose. Check your agenda!',
        5,
        0,
      );

      // Good Afternoon: 12:00 PM
      await _scheduleDailyNotification(
        1002,
        '☀️ Good Afternoon',
        'Halfway through! How is your progress?',
        12,
        0,
      );

      // Good Evening: 5:00 PM
      await _scheduleDailyNotification(
        1003,
        '🌇 Good Evening',
        'Winding down? Review your achievements.',
        17,
        0,
      );

      // Good Night: 9:00 PM
      await _scheduleDailyNotification(
        1004,
        '🌙 Good Night',
        'Rest well. Your manifest is ready for tomorrow.',
        21,
        0,
      );

      debugPrint('Greeting notifications scheduled');
    } catch (e) {
      debugPrint('Failed to schedule greeting notifications: $e');
    }
  }

  Future<void> _scheduleDailyNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'greetings_channel',
          'Greetings',
          channelDescription:
              'Time-based morning, afternoon, and evening greetings',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  String _buildNotificationBody(Event event) {
    final buffer = StringBuffer();

    if (event.isAllDay) {
      buffer.write('All day event');
    } else if (event.startTime != null) {
      buffer.write('Starts at ${_formatTime(event.startTime!)}');
      if (event.endTime != null) {
        buffer.write(' - ${_formatTime(event.endTime!)}');
      }
    }

    if (event.location != null && event.location!.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write('Location: ${event.location}');
    }

    if (event.description != null && event.description!.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(event.description);
    }

    return buffer.isNotEmpty ? buffer.toString() : 'Event reminder';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  int _generateNotificationId(String eventId, DateTime reminderTime) {
    return (eventId.hashCode + reminderTime.hashCode).abs() % 100000;
  }

  Future<void> cancelEventNotifications(String eventId) async {
    try {
      // Get all pending notifications
      final pendingNotifications = await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();

      // Cancel notifications that match this event
      for (final notification in pendingNotifications) {
        if (notification.payload == eventId) {
          await _flutterLocalNotificationsPlugin.cancel(notification.id);
        }
      }

      debugPrint('Cancelled notifications for event: $eventId');
    } catch (e) {
      debugPrint('Failed to cancel event notifications: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      debugPrint('Failed to get pending notifications: $e');
      return [];
    }
  }

  Future<void> showImmediateNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF2196F3),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show immediate notification: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to event details
    // This will be implemented when we have navigation set up
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? notificationsEnabled = await androidImplementation
          ?.areNotificationsEnabled();

      return notificationsEnabled ?? false;
    } catch (e) {
      debugPrint('Failed to check if notifications are enabled: $e');
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      // Note: openNotificationSettings might not be available in all versions
      // This is a placeholder for opening app notification settings
      debugPrint('Opening notification settings...');
    } catch (e) {
      debugPrint('Failed to open notification settings: $e');
    }
  }
}
