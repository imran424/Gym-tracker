# Gym Tracker — Project Reference

## Stack

- **Flutter** (Dart) — cross-platform mobile app
- **Provider** (`ChangeNotifier`) — state management
- **Hive** — local key-value database with typed adapters
- **intl** — date formatting
- **uuid** — ID generation

## Architecture

```
lib/
  main.dart              # Entry point, Hive init, adapter registration, ChangeNotifierProvider
  models/                # Hive-typed data models + generated adapters (*.g.dart)
  providers/
    gym_provider.dart    # All state + persistence logic (single provider)
  screens/
    home_screen.dart     # "Today" tab
    calendar_screen.dart # "History" tab
    sets_screen.dart     # Workout sets management
    schedule_screen.dart # Weekly schedule
    set_editor_screen.dart
  widgets/
    exercise_tile.dart   # Single exercise row (checkbox + weight badge)
    stat_card.dart
    progress_bar.dart
    cal_day_cell.dart
  theme/
    app_theme.dart       # Dark theme constants (kBg, kSurface, kGreen, kGreenDim, kTextMuted, kTextPrimary, kBorder)
```

## Data Models

All models use Hive typed adapters. **Never edit `*.g.dart` files with `build_runner` — adapters are maintained manually.**

### Exercise (typeId: 0)
| Field | HiveField | Type | Notes |
|-------|-----------|------|-------|
| id | 0 | String | UUID v4 |
| name | 1 | String | e.g. "Bench Press" |
| meta | 2 | String | e.g. "3 × 10" |

Exercises are stored **inline** inside `WorkoutSet` (denormalised).

### WorkoutSet (typeId: 1)
| Field | HiveField | Type |
|-------|-----------|------|
| id | 0 | String |
| name | 1 | String |
| exercises | 2 | List\<Exercise\> |
| createdAt | 3 | DateTime |

Stored in Hive box `workout_sets`, keyed by `set.id`.

### WeekSchedule (typeId: 2)
| Field | HiveField | Type | Notes |
|-------|-----------|------|-------|
| dayAssignments | 0 | List\<String?\> | Index 0=Mon…6=Sun; null = rest day |

Single instance in box `schedule` at key `0`.

### WorkoutLog (typeId: 3)
| Field | HiveField | Type | Notes |
|-------|-----------|------|-------|
| dateKey | 0 | String | "YYYY-MM-DD" |
| workoutSetId | 1 | String? | |
| completedExerciseIds | 2 | List\<String\> | |
| completed | 3 | bool | true = workout marked complete |
| loggedAt | 4 | DateTime | |
| weights | 5 | Map\<String, double\>? | exerciseId → kg; null for old records |

Stored in box `workout_logs`, keyed by `dateKey`. Field 5 (`weights`) was added manually — old records without it deserialise to `null` safely.

## Key Provider Methods (GymProvider)

### Today
- `todayKey` — current date as "YYYY-MM-DD"
- `getTodaySet()` — scheduled `WorkoutSet` for today (or null = rest day)
- `getLog(dateKey)` — `WorkoutLog?` for a date

### Exercise completion
- `toggleExercise(dateKey, exId, setId)` — check/uncheck; preserves weights
- `completeWorkout(dateKey, set)` — marks all exercises done + `completed=true`; preserves weights
- `undoComplete(dateKey)` — sets `completed=false`
- `isChecked(dateKey, exId)` → bool

### Weight tracking
- `getExerciseWeight(dateKey, exId)` → `double?`
- `setExerciseWeight(dateKey, exId, weight, setId)` — saves weight for one exercise; clears if null/0
- `getLastWeight(exId)` → `double?` — most recent weight from any past log (excludes today)

### Stats
- `currentStreak` — consecutive completed days
- `workoutsInLast(days)` — count of completed logs in last N days
- `getLast30DayKeys()` — list of 30 dateKey strings for the calendar

## Today Tab (`home_screen.dart`)

- Shows date header, 3 stat cards (Streak, This Week, 30 Days), workout card or rest day card.
- Workout card: set name pill → progress bar → exercise list → Complete button.
- Each `ExerciseTile` has a tappable **weight badge** ("— kg" / "X kg").
- **When `isDone=true`**: tiles are `locked=true` — checkboxes and weight badges are non-interactive. Editing requires pressing "Undo".
- **Previous weight hint**: each tile shows "prev: X kg" (from `getLastWeight`) below the meta when no weight is entered yet for today.
- **Total weight row**: appears below the exercise list when at least one weight is logged; sums all entered weights for the day.

## History Tab (`calendar_screen.dart`)

- 30-day calendar grid; completed days are green and tappable.
- Tapping a completed day opens a `DraggableScrollableSheet` with:
  - Date + set name pill + "X/Y done" count
  - Per-exercise list: green check / grey circle, name, meta, weight badge (if logged)
- "Reset all data" button at the bottom (with confirmation dialog).

## ExerciseTile (`widgets/exercise_tile.dart`)

Props:
| Prop | Type | Purpose |
|------|------|---------|
| exercise | Exercise | data |
| isChecked | bool | checkbox state |
| onTap | VoidCallback | toggle checkbox |
| weight | double? | today's logged weight |
| onWeightChanged | ValueChanged\<double?\>? | save weight callback |
| locked | bool | disables all interaction when workout is logged |
| previousWeight | double? | last recorded weight from a past session |

Weight input dialog uses `TextInputType.numberWithOptions(decimal: true)` + `FilteringTextInputFormatter` — numbers only.

## Hive Adapter Convention

When adding a new field to a model:
1. Add `@HiveField(N)` in the model class with the next available index.
2. In the `.g.dart` adapter:
   - Increment the `writeByte(N)` count in `write()`
   - Add `..writeByte(N) ..write(obj.newField)` to the write chain
   - Add `newField: fields[N] as Type?` in `read()` (null-safe for backward compat)
3. Do **not** run `build_runner` — adapters are hand-maintained.

## Theme Constants (`theme/app_theme.dart`)

| Constant | Usage |
|----------|-------|
| `kBg` | Scaffold background |
| `kSurface` | Card / bottom sheet background |
| `kGreen` | Primary accent (`#4ADE80`) |
| `kGreenDim` | Green tinted background for badges/banners |
| `kTextPrimary` | Main text |
| `kTextMuted` | Secondary / disabled text |
| `kBorder` | Dividers and drag handles |
