import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/week_schedule.dart';
import '../models/workout_log.dart';
import '../models/workout_set.dart';

class GymProvider extends ChangeNotifier {
  static const _setsBox     = 'workout_sets';
  static const _logsBox     = 'workout_logs';
  static const _scheduleBox = 'schedule';

  late Box<WorkoutSet>   _sets;
  late Box<WorkoutLog>   _logs;
  late Box<WeekSchedule> _schedule;

  final _uuid = const Uuid();
  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _sets     = await Hive.openBox<WorkoutSet>(_setsBox);
    _logs     = await Hive.openBox<WorkoutLog>(_logsBox);
    _schedule = await Hive.openBox<WeekSchedule>(_scheduleBox);

    if (_sets.isEmpty) await _seedDefaults();

    _initialized = true;
    notifyListeners();
  }

  // ── Accessors ─────────────────────────────────────────────────────────────

  List<WorkoutSet> get workoutSets {
    return _sets.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  WeekSchedule get schedule =>
      _schedule.get(0) ?? WeekSchedule.empty();

  WorkoutSet? getSetById(String? id) {
    if (id == null) return null;
    try {
      return _sets.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  WorkoutLog? getLog(String dateKey) => _logs.get(dateKey);

  // ── Today ─────────────────────────────────────────────────────────────────

  String get todayKey => _dateKey(DateTime.now());

  int get _todayWeekdayIndex => DateTime.now().weekday - 1; // 0=Mon…6=Sun

  WorkoutSet? getTodaySet() =>
      getSetById(schedule.dayAssignments[_todayWeekdayIndex]);

  // ── Exercise checking ─────────────────────────────────────────────────────

  bool isChecked(String dateKey, String exId) =>
      _logs.get(dateKey)?.completedExerciseIds.contains(exId) ?? false;

  void toggleExercise(String dateKey, String exId, String? setId) {
    final log = _logs.get(dateKey);
    final ids = List<String>.from(log?.completedExerciseIds ?? []);
    ids.contains(exId) ? ids.remove(exId) : ids.add(exId);

    _logs.put(
      dateKey,
      WorkoutLog(
        dateKey: dateKey,
        workoutSetId: setId,
        completedExerciseIds: ids,
        completed: log?.completed ?? false,
        loggedAt: log?.loggedAt ?? DateTime.now(),
        weights: log?.weights,
      ),
    );
    notifyListeners();
  }

  void completeWorkout(String dateKey, WorkoutSet? set) {
    final log = _logs.get(dateKey);
    _logs.put(
      dateKey,
      WorkoutLog(
        dateKey: dateKey,
        workoutSetId: set?.id,
        completedExerciseIds: set?.exercises.map((e) => e.id).toList() ?? [],
        completed: true,
        loggedAt: DateTime.now(),
        weights: log?.weights,
      ),
    );
    notifyListeners();
  }

  // ── Weight tracking ───────────────────────────────────────────────────────

  double? getExerciseWeight(String dateKey, String exId) =>
      _logs.get(dateKey)?.weights?[exId];

  double? getLastWeight(String exId) {
    final today = todayKey;
    final sorted = _logs.values
        .where((log) => log.dateKey != today)
        .toList()
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    for (final log in sorted) {
      final w = log.weights?[exId];
      if (w != null && w > 0) return w;
    }
    return null;
  }

  void setExerciseWeight(
      String dateKey, String exId, double? weight, String? setId) {
    final log = _logs.get(dateKey);
    final weights = Map<String, double>.from(log?.weights ?? {});
    if (weight == null || weight <= 0) {
      weights.remove(exId);
    } else {
      weights[exId] = weight;
    }
    _logs.put(
      dateKey,
      WorkoutLog(
        dateKey: dateKey,
        workoutSetId: log?.workoutSetId ?? setId,
        completedExerciseIds: log?.completedExerciseIds ?? [],
        completed: log?.completed ?? false,
        loggedAt: log?.loggedAt ?? DateTime.now(),
        weights: weights,
      ),
    );
    notifyListeners();
  }

  void undoComplete(String dateKey) {
    final log = _logs.get(dateKey);
    if (log == null) return;
    _logs.put(dateKey, log.copyWith(completed: false));
    notifyListeners();
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  int get currentStreak {
    var d = _today();
    // Start from yesterday if today isn't done yet
    if (!(_logs.get(_dateKey(d))?.completed ?? false)) {
      d = d.subtract(const Duration(days: 1));
    }
    int count = 0;
    while (_logs.get(_dateKey(d))?.completed ?? false) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  int workoutsInLast(int days) {
    int count = 0;
    final now = _today();
    for (int i = 0; i < days; i++) {
      final key = _dateKey(now.subtract(Duration(days: i)));
      if (_logs.get(key)?.completed ?? false) count++;
    }
    return count;
  }

  List<String> getLast30DayKeys() {
    final now = _today();
    return List.generate(30, (i) => _dateKey(now.subtract(Duration(days: 29 - i))));
  }

  // ── Workout Sets CRUD ─────────────────────────────────────────────────────

  Future<void> addWorkoutSet(String name) async {
    final set = WorkoutSet(
      id: _uuid.v4(),
      name: name.trim(),
      exercises: const [],
      createdAt: DateTime.now(),
    );
    await _sets.put(set.id, set);
    notifyListeners();
  }

  Future<void> deleteWorkoutSet(String id) async {
    await _sets.delete(id);
    // Clear from any scheduled day
    final sched = schedule;
    final updated = List<String?>.from(sched.dayAssignments);
    for (int i = 0; i < updated.length; i++) {
      if (updated[i] == id) updated[i] = null;
    }
    await _schedule.put(0, WeekSchedule(dayAssignments: updated));
    notifyListeners();
  }

  Future<void> renameWorkoutSet(String id, String newName) async {
    final set = _sets.get(id);
    if (set == null) return;
    await _sets.put(id, set.copyWith(name: newName.trim()));
    notifyListeners();
  }

  Future<void> addExerciseToSet(String setId, String name, String meta) async {
    final set = _sets.get(setId);
    if (set == null) return;
    final ex = Exercise(id: _uuid.v4(), name: name.trim(), meta: meta.trim());
    await _sets.put(setId, set.copyWith(exercises: [...set.exercises, ex]));
    notifyListeners();
  }

  Future<void> removeExerciseFromSet(String setId, String exId) async {
    final set = _sets.get(setId);
    if (set == null) return;
    await _sets.put(
      setId,
      set.copyWith(exercises: set.exercises.where((e) => e.id != exId).toList()),
    );
    notifyListeners();
  }

  Future<void> reorderExercises(String setId, int oldIndex, int newIndex) async {
    final set = _sets.get(setId);
    if (set == null) return;
    final list = List<Exercise>.from(set.exercises);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    await _sets.put(setId, set.copyWith(exercises: list));
    notifyListeners();
  }

  // ── Schedule ──────────────────────────────────────────────────────────────

  Future<void> assignDay(int weekdayIndex, String? setId) async {
    await _schedule.put(0, schedule.withDay(weekdayIndex, setId));
    notifyListeners();
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  Future<void> resetAll() async {
    await _sets.clear();
    await _logs.clear();
    await _schedule.clear();
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ── Seed defaults ─────────────────────────────────────────────────────────

  Future<void> _seedDefaults() async {
    ex(String name, String meta) =>
        Exercise(id: _uuid.v4(), name: name, meta: meta);

    final push = WorkoutSet(
      id: _uuid.v4(), name: 'Push Day',
      exercises: [
        ex('Bench Press',     '3 × 10'),
        ex('Overhead Press',  '3 × 10'),
        ex('Incline Press',   '3 × 12'),
        ex('Tricep Pushdown', '3 × 15'),
        ex('Lateral Raise',   '3 × 15'),
      ],
      createdAt: DateTime.now(),
    );

    final pull = WorkoutSet(
      id: _uuid.v4(), name: 'Pull Day',
      exercises: [
        ex('Deadlift',    '3 × 5'),
        ex('Pull-ups',    '3 × 8'),
        ex('Barbell Row', '3 × 10'),
        ex('Face Pulls',  '3 × 15'),
        ex('Bicep Curl',  '3 × 12'),
      ],
      createdAt: DateTime.now(),
    );

    final legs = WorkoutSet(
      id: _uuid.v4(), name: 'Legs',
      exercises: [
        ex('Squat',              '3 × 10'),
        ex('Romanian Deadlift',  '3 × 10'),
        ex('Leg Press',          '3 × 12'),
        ex('Calf Raises',        '3 × 20'),
        ex('Leg Curl',           '3 × 12'),
      ],
      createdAt: DateTime.now(),
    );

    await _sets.put(push.id, push);
    await _sets.put(pull.id, pull);
    await _sets.put(legs.id, legs);

    // Mon=Push, Tue=Pull, Wed=Legs, Thu=Push, Fri=Pull, Sat=Legs, Sun=Rest
    await _schedule.put(0, WeekSchedule(dayAssignments: [
      push.id, pull.id, legs.id, push.id, pull.id, legs.id, null,
    ]));
  }
}
