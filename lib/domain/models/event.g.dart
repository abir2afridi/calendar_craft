// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      date: fields[3] as DateTime,
      startTime: fields[4] as DateTime?,
      endTime: fields[5] as DateTime?,
      isAllDay: fields[6] as bool,
      category: fields[7] as EventCategory,
      color: fields[8] as String,
      reminderTimes: (fields[9] as List).cast<DateTime>(),
      repeatType: fields[10] as RepeatType,
      location: fields[11] as String?,
      priority: fields[12] as EventPriority,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.isAllDay)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.color)
      ..writeByte(9)
      ..write(obj.reminderTimes)
      ..writeByte(10)
      ..write(obj.repeatType)
      ..writeByte(11)
      ..write(obj.location)
      ..writeByte(12)
      ..write(obj.priority)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      isAllDay: json['is_all_day'] as bool,
      category: $enumDecode(_$EventCategoryEnumMap, json['category']),
      color: json['color'] as String,
      reminderTimes: (json['reminder_times'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      repeatType: $enumDecode(_$RepeatTypeEnumMap, json['repeat_type']),
      location: json['location'] as String?,
      priority: $enumDecode(_$EventPriorityEnumMap, json['priority']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'is_all_day': instance.isAllDay,
      'category': _$EventCategoryEnumMap[instance.category]!,
      'color': instance.color,
      'reminder_times':
          instance.reminderTimes.map((e) => e.toIso8601String()).toList(),
      'repeat_type': _$RepeatTypeEnumMap[instance.repeatType]!,
      'location': instance.location,
      'priority': _$EventPriorityEnumMap[instance.priority]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$EventCategoryEnumMap = {
  EventCategory.work: 'work',
  EventCategory.personal: 'personal',
  EventCategory.health: 'health',
  EventCategory.education: 'education',
  EventCategory.entertainment: 'entertainment',
  EventCategory.social: 'social',
  EventCategory.travel: 'travel',
  EventCategory.other: 'other',
};

const _$RepeatTypeEnumMap = {
  RepeatType.none: 'none',
  RepeatType.daily: 'daily',
  RepeatType.weekly: 'weekly',
  RepeatType.monthly: 'monthly',
  RepeatType.yearly: 'yearly',
  RepeatType.custom: 'custom',
};

const _$EventPriorityEnumMap = {
  EventPriority.low: 'low',
  EventPriority.medium: 'medium',
  EventPriority.high: 'high',
};
