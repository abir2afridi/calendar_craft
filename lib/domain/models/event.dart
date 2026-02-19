import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

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
  work,
  personal,
  health,
  education,
  entertainment,
  social,
  travel,
  other;

  String get displayName {
    switch (this) {
      case EventCategory.work:
        return 'Work';
      case EventCategory.personal:
        return 'Personal';
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
      case EventCategory.other:
        return 'Other';
    }
  }

  String get color {
    switch (this) {
      case EventCategory.work:
        return '#2196F3'; // Blue
      case EventCategory.personal:
        return '#4CAF50'; // Green
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
        return 'No Repeat';
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
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'title')
  final String title;

  @HiveField(2)
  @JsonKey(name: 'description')
  final String? description;

  @HiveField(3)
  @JsonKey(name: 'date')
  final DateTime date;

  @HiveField(4)
  @JsonKey(name: 'start_time')
  final DateTime? startTime;

  @HiveField(5)
  @JsonKey(name: 'end_time')
  final DateTime? endTime;

  @HiveField(6)
  @JsonKey(name: 'is_all_day')
  final bool isAllDay;

  @HiveField(7)
  @JsonKey(name: 'category')
  final EventCategory category;

  @HiveField(8)
  @JsonKey(name: 'color')
  final String color;

  @HiveField(9)
  @JsonKey(name: 'reminder_times')
  final List<DateTime> reminderTimes;

  @HiveField(10)
  @JsonKey(name: 'repeat_type')
  final RepeatType repeatType;

  @HiveField(11)
  @JsonKey(name: 'location')
  final String? location;

  @HiveField(12)
  @JsonKey(name: 'priority')
  final EventPriority priority;

  @HiveField(13)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(14)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.isAllDay,
    required this.category,
    required this.color,
    required this.reminderTimes,
    required this.repeatType,
    this.location,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
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
    String? color,
    List<DateTime>? reminderTimes,
    RepeatType? repeatType,
    String? location,
    EventPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      color: color ?? this.color,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      repeatType: repeatType ?? this.repeatType,
      location: location ?? this.location,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
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
      ];

  @override
  String toString() {
    return 'Event(id: $id, title: $title, date: $date)';
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
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
