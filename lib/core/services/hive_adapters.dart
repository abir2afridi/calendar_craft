import 'package:hive/hive.dart';
import '../../domain/models/event.dart';

class EventPriorityAdapter extends TypeAdapter<EventPriority> {
  @override
  final int typeId = 2;

  @override
  EventPriority read(BinaryReader reader) {
    final index = reader.readByte();
    return EventPriority.values[index];
  }

  @override
  void write(BinaryWriter writer, EventPriority obj) {
    writer.writeByte(obj.index);
  }
}

class EventCategoryAdapter extends TypeAdapter<EventCategory> {
  @override
  final int typeId = 3;

  @override
  EventCategory read(BinaryReader reader) {
    final index = reader.readByte();
    return EventCategory.values[index];
  }

  @override
  void write(BinaryWriter writer, EventCategory obj) {
    writer.writeByte(obj.index);
  }
}

class RepeatTypeAdapter extends TypeAdapter<RepeatType> {
  @override
  final int typeId = 4;

  @override
  RepeatType read(BinaryReader reader) {
    final index = reader.readByte();
    return RepeatType.values[index];
  }

  @override
  void write(BinaryWriter writer, RepeatType obj) {
    writer.writeByte(obj.index);
  }
}
