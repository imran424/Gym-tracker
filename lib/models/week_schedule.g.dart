// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeekScheduleAdapter extends TypeAdapter<WeekSchedule> {
  @override
  final int typeId = 2;

  @override
  WeekSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeekSchedule(
      dayAssignments: (fields[0] as List).cast<String?>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeekSchedule obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.dayAssignments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeekScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
