import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_tile.dart';
import '../widgets/progress_bar.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<GymProvider>();
    final today     = provider.todayKey;
    final todaySet  = provider.getTodaySet();
    final log       = provider.getLog(today);
    final isDone    = log?.completed ?? false;
    final checked   = log?.completedExerciseIds.length ?? 0;
    final total     = todaySet?.exercises.length ?? 0;
    final totalWeight = todaySet?.exercises
        .map((e) => provider.getExerciseWeight(today, e.id) ?? 0.0)
        .fold(0.0, (a, b) => a + b) ?? 0.0;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Text(
                DateFormat('EEEE').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                DateFormat('MMMM d, y').format(DateTime.now()),
                style: const TextStyle(fontSize: 13, color: kTextMuted),
              ),
              const SizedBox(height: 20),

              // ── Stats ─────────────────────────────────────────────────────
              Row(
                children: [
                  StatCard(label: 'Streak 🔥', value: '${provider.currentStreak}'),
                  const SizedBox(width: 10),
                  StatCard(label: 'This Week', value: '${provider.workoutsInLast(7)}'),
                  const SizedBox(width: 10),
                  StatCard(label: '30 Days',   value: '${provider.workoutsInLast(30)}'),
                ],
              ),
              const SizedBox(height: 16),

              // ── Workout or Rest ───────────────────────────────────────────
              if (todaySet != null) ...[
                // Done banner
                if (isDone) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: kGreenDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1A4A2E)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: kGreen, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Workout logged for today!',
                            style: TextStyle(
                              color: kGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => provider.undoComplete(today),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Undo',
                            style: TextStyle(color: kGreen, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Workout card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Set name pill + progress
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kGreenDim,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              todaySet.name,
                              style: const TextStyle(
                                color: kGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GymProgressBar(done: checked, total: total),
                      const Divider(
                        color: Color(0xFF252525),
                        height: 24,
                      ),

                      // Exercise list
                      ...todaySet.exercises.map(
                        (ex) => ExerciseTile(
                          exercise: ex,
                          isChecked: provider.isChecked(today, ex.id),
                          onTap: () => provider.toggleExercise(
                              today, ex.id, todaySet.id),
                          weight: provider.getExerciseWeight(today, ex.id),
                          onWeightChanged: (w) => provider.setExerciseWeight(
                              today, ex.id, w, todaySet.id),
                          locked: isDone,
                          previousWeight: provider.getLastWeight(ex.id),
                        ),
                      ),
                      if (totalWeight > 0) ...[
                        const Divider(
                          color: Color(0xFF252525),
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: kTextMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              totalWeight % 1 == 0
                                  ? '${totalWeight.toInt()} kg'
                                  : '$totalWeight kg',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Complete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isDone ? null : () => provider.completeWorkout(today, todaySet),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDone ? const Color(0xFF151F17) : kGreen,
                      foregroundColor:
                          isDone ? const Color(0xFF2A5A35) : Colors.black,
                      disabledBackgroundColor: const Color(0xFF151F17),
                      disabledForegroundColor: const Color(0xFF2A5A35),
                    ),
                    child: Text(isDone ? '✓  Logged' : 'Mark Workout Complete'),
                  ),
                ),
              ] else ...[
                // Rest day
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.self_improvement, size: 48, color: kTextMuted),
                      SizedBox(height: 14),
                      Text(
                        'Rest Day',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'No workout scheduled.\nGo to Schedule to assign one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextMuted, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
