import 'package:hive/hive.dart';

part 'workout_log.g.dart';

@HiveType(typeId: 3)
class WorkoutLog {
  @HiveField(0)
  final String dateKey; // "2026-05-04"

  @HiveField(1)
  final String? workoutSetId;

  @HiveField(2)
  final List<String> completedExerciseIds;

  @HiveField(3)
  final bool completed;

  @HiveField(4)
  final DateTime loggedAt;

  @HiveField(5)
  final Map<String, double>? weights;

  const WorkoutLog({
    required this.dateKey,
    this.workoutSetId,
    required this.completedExerciseIds,
    this.completed = false,
    required this.loggedAt,
    this.weights,
  });

  WorkoutLog copyWith({
    List<String>? completedExerciseIds,
    bool? completed,
    Map<String, double>? weights,
  }) {
    return WorkoutLog(
      dateKey: dateKey,
      workoutSetId: workoutSetId,
      completedExerciseIds: completedExerciseIds ?? this.completedExerciseIds,
      completed: completed ?? this.completed,
      loggedAt: loggedAt,
      weights: weights ?? this.weights,
    );
  }
}
