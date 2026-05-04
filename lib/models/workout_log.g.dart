// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogAdapter extends TypeAdapter<WorkoutLog> {
  @override
  final int typeId = 3;

  @override
  WorkoutLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLog(
      dateKey: fields[0] as String,
      workoutSetId: fields[1] as String?,
      completedExerciseIds: (fields[2] as List).cast<String>(),
      completed: fields[3] as bool,
      loggedAt: fields[4] as DateTime,
      weights: (fields[5] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.workoutSetId)
      ..writeByte(2)
      ..write(obj.completedExerciseIds)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.loggedAt)
      ..writeByte(5)
      ..write(obj.weights);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
