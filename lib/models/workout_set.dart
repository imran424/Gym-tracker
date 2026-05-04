import 'package:hive/hive.dart';
import 'exercise.dart';

part 'workout_set.g.dart';

@HiveType(typeId: 1)
class WorkoutSet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Exercise> exercises;

  @HiveField(3)
  final DateTime createdAt;

  const WorkoutSet({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  WorkoutSet copyWith({String? name, List<Exercise>? exercises}) {
    return WorkoutSet(
      id: id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt,
    );
  }
}
