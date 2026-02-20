import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'event.g.dart';

enum EventPriority {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case EventPriority.low:
        return 'Low';
      case EventPriority.medium:
        return 'Medium';
      case EventPriority.high:
        return 'High';
    }
  }
}

enum EventCategory {
  personal,
  work,
  health,
  education,
  entertainment,
  social,
  travel,
  birthday,
  other;

  String get displayName {
    switch (this) {
      case EventCategory.personal:
        return 'Personal';
      case EventCategory.work:
        return 'Work';
      case EventCategory.health:
        return 'Health';
      case EventCategory.education:
        return 'Education';
      case EventCategory.entertainment:
        return 'Entertainment';
      case EventCategory.social:
        return 'Social';
      case EventCategory.travel:
        return 'Travel';
      case EventCategory.birthday:
        return 'Birthday';
      case EventCategory.other:
        return 'Other';
    }
  }

  String get color {
    switch (this) {
      case EventCategory.personal:
        return '#4CAF50'; // Green
      case EventCategory.work:
        return '#2196F3'; // Blue
      case EventCategory.health:
        return '#F44336'; // Red
      case EventCategory.education:
        return '#9C27B0'; // Purple
      case EventCategory.entertainment:
        return '#FF9800'; // Orange
      case EventCategory.social:
        return '#E91E63'; // Pink
      case EventCategory.travel:
        return '#00BCD4'; // Cyan
      case EventCategory.birthday:
        return '#FF6B9D'; // Pink Rose
      case EventCategory.other:
        return '#607D8B'; // Blue Grey
    }
  }
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  String get displayName {
    switch (this) {
      case RepeatType.none:
        return 'None';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
      case RepeatType.custom:
        return 'Custom';
    }
  }
}

@HiveType(typeId: 0)
@JsonSerializable()
class Event extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final DateTime? startTime;

  @HiveField(5)
  final DateTime? endTime;

  @HiveField(6)
  final bool isAllDay;

  @HiveField(7)
  final EventCategory category;

  @HiveField(8)
  final EventPriority priority;

  @HiveField(9)
  final RepeatType repeatType;

  @HiveField(10)
  final String color;

  @HiveField(11)
  final List<DateTime> reminderTimes;

  @HiveField(12)
  final String? location;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  @HiveField(15, defaultValue: true)
  final bool isSyncPending;

  @HiveField(16)
  final DateTime? lastSyncedAt;

  @HiveField(17, defaultValue: false)
  final bool isCompleted;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.category = EventCategory.personal,
    this.priority = EventPriority.medium,
    this.repeatType = RepeatType.none,
    this.color = '#2196F3',
    this.reminderTimes = const [],
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.isSyncPending = true,
    this.lastSyncedAt,
    this.isCompleted = false,
  });

  factory Event.create({
    required String title,
    String? description,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
    bool isAllDay = false,
    EventCategory category = EventCategory.personal,
    String? color,
    List<DateTime>? reminderTimes,
    RepeatType repeatType = RepeatType.none,
    String? location,
    EventPriority priority = EventPriority.medium,
  }) {
    final now = DateTime.now();
    return Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      category: category,
      color: color ?? category.color,
      reminderTimes: reminderTimes ?? [],
      repeatType: repeatType,
      location: location,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      isSyncPending: true,
      isCompleted: false,
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    EventCategory? category,
    EventPriority? priority,
    RepeatType? repeatType,
    String? color,
    List<DateTime>? reminderTimes,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSyncPending,
    DateTime? lastSyncedAt,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      repeatType: repeatType ?? this.repeatType,
      color: color ?? this.color,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSyncPending: isSyncPending ?? this.isSyncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    startTime,
    endTime,
    isAllDay,
    category,
    color,
    reminderTimes,
    repeatType,
    location,
    priority,
    createdAt,
    updatedAt,
    isSyncPending,
    lastSyncedAt,
    isCompleted,
  ];

  @override
  String toString() {
    return 'Event(id: $id, title: $title, date: $date)';
  }

  Color get uiColor {
    final hexCode = color.replaceFirst('#', '0xFF');
    return Color(int.parse(hexCode));
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get isPast {
    final now = DateTime.now();
    if (isAllDay) {
      return date.isBefore(DateTime(now.year, now.month, now.day));
    } else {
      final eventEnd = endTime ?? date;
      return eventEnd.isBefore(now);
    }
  }

  bool get isFuture {
    final now = DateTime.now();
    if (isAllDay) {
      return date.isAfter(DateTime(now.year, now.month, now.day));
    } else {
      final eventStart = startTime ?? date;
      return eventStart.isAfter(now);
    }
  }

  String get timeDisplay {
    if (isAllDay) return 'All day';

    if (startTime != null && endTime != null) {
      final start = _formatTime(startTime!);
      final end = _formatTime(endTime!);
      return '$start - $end';
    } else if (startTime != null) {
      return _formatTime(startTime!);
    } else {
      return 'No time';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
