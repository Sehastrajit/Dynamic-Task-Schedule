// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_table_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeTableEntryAdapter extends TypeAdapter<TimeTableEntry> {
  @override
  final int typeId = 0;

  @override
  TimeTableEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeTableEntry(
      id: fields[0] as String,
      task: fields[1] as String,
      time: fields[2] as String,
      duration: fields[3] as String,
      priority: fields[4] as String,
      dateTime: fields[5] as DateTime,
      frequency: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimeTableEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.task)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.dateTime)
      ..writeByte(6)
      ..write(obj.frequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeTableEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
