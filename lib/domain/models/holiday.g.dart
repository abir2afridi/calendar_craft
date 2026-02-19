// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HolidayAdapter extends TypeAdapter<Holiday> {
  @override
  final int typeId = 1;

  @override
  Holiday read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Holiday(
      id: fields[0] as String,
      name: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as String,
      country: fields[4] as String,
      description: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Holiday obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.country)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Holiday _$HolidayFromJson(Map<String, dynamic> json) => Holiday(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      country: json['country'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$HolidayToJson(Holiday instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'type': instance.type,
      'country': instance.country,
      'description': instance.description,
    };
