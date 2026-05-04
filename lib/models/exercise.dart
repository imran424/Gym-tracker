import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String meta;

  const Exercise({
    required this.id,
    required this.name,
    this.meta = '',
  });

  Exercise copyWith({String? name, String? meta}) {
    return Exercise(id: id, name: name ?? this.name, meta: meta ?? this.meta);
  }
}
