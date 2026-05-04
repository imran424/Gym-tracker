import 'package:hive/hive.dart';

part 'week_schedule.g.dart';

@HiveType(typeId: 2)
class WeekSchedule {
  // index 0=Monday … 6=Sunday; value = WorkoutSet.id or null (rest day)
  @HiveField(0)
  final List<String?> dayAssignments;

  const WeekSchedule({required this.dayAssignments});

  factory WeekSchedule.empty() =>
      const WeekSchedule(dayAssignments: [null, null, null, null, null, null, null]);

  WeekSchedule withDay(int index, String? setId) {
    final updated = List<String?>.from(dayAssignments);
    updated[index] = setId;
    return WeekSchedule(dayAssignments: updated);
  }
}
