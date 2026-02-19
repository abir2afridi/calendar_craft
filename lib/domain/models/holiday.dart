import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'holiday.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Holiday extends Equatable {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'name')
  final String name;

  @HiveField(2)
  @JsonKey(name: 'date')
  final DateTime date;

  @HiveField(3)
  @JsonKey(name: 'type')
  final String type;

  @HiveField(4)
  @JsonKey(name: 'country')
  final String country;

  @HiveField(5)
  @JsonKey(name: 'description')
  final String? description;

  const Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    required this.country,
    this.description,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) => _$HolidayFromJson(json);
  Map<String, dynamic> toJson() => _$HolidayToJson(this);

  @override
  List<Object?> get props => [id, name, date, type, country, description];

  @override
  String toString() {
    return 'Holiday(id: $id, name: $name, date: $date, country: $country)';
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String get color => '#FF5252'; // Red color for holidays
}
