import 'package:equatable/equatable.dart';

import 'package:hive/hive.dart';

part 'holiday.g.dart';

@HiveType(typeId: 1)
@HiveType(typeId: 1)
class Holiday extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String countryCode;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String color;

  const Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    required this.countryCode,
    this.description,
    this.color = '#FF5252',
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    // Handle Calendarific API structure
    // json['date']['iso'] example: "2024-01-01" or "2024-01-01T00:00:00+00:00"
    String? dateStr;
    if (json['date'] != null && json['date'] is Map) {
      dateStr = json['date']['iso'] as String?;
    } else {
      dateStr = json['date'] as String?;
    }

    if (dateStr == null) {
      throw ArgumentError('Missing date in holiday JSON');
    }

    // Parse date securely
    final parsedDate = DateTime.parse(dateStr);
    final normalizedDate = DateTime.utc(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );

    // Types in Calendarific are usually a List<dynamic>
    String holidayType = 'Public';
    if (json['type'] != null) {
      if (json['type'] is List) {
        holidayType = (json['type'] as List).join(', ');
      } else {
        holidayType = json['type'].toString();
      }
    }

    final countryCode = json['country'] != null && json['country'] is Map
        ? json['country']['id']?.toString().toUpperCase() ?? ''
        : json['countryCode']?.toString().toUpperCase() ?? '';

    final name = json['name'] as String? ?? 'Untitled Holiday';

    return Holiday(
      id: '${countryCode}_${dateStr.split('T').first}_$name'.replaceAll(
        ' ',
        '_',
      ),
      name: name,
      date: normalizedDate,
      type: holidayType,
      countryCode: countryCode,
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#FF5252',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'type': type,
    'countryCode': countryCode,
    'description': description,
    'color': color,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    date,
    type,
    countryCode,
    description,
    color,
  ];

  @override
  String toString() {
    return 'Holiday(id: $id, name: $name, date: $date, countryCode: $countryCode)';
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
