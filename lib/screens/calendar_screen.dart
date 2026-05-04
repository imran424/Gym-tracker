import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cal_day_cell.dart';
import '../widgets/stat_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GymProvider>();
    final todayKey = provider.todayKey;
    final days     = provider.getLast30DayKeys();
    final firstDate = DateTime.parse('${days.first}T00:00:00');
    final offset    = firstDate.weekday - 1; // 0=Mon offset

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              Row(
                children: [
                  StatCard(label: 'Streak 🔥', value: '${provider.currentStreak}'),
                  const SizedBox(width: 10),
                  StatCard(label: 'This Week', value: '${provider.workoutsInLast(7)}'),
                  const SizedBox(width: 10),
                  StatCard(label: '30 Days',   value: '${provider.workoutsInLast(30)}'),
                ],
              ),
              const SizedBox(height: 24),

              // Calendar card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 30 Days',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Day-of-week header
                    Row(
                      children: _dayLabels
                          .map(
                            (l) => Expanded(
                              child: Text(
                                l,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: kTextMuted,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 6),

                    // Calendar grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: offset + days.length,
                      itemBuilder: (_, i) {
                        // Empty offset cells
                        if (i < offset) return const SizedBox.shrink();

                        final dateKey = days[i - offset];
                        final date = DateTime.parse('${dateKey}T00:00:00');
                        final log  = provider.getLog(dateKey);
                        final workedOut = log?.completed ?? false;
                        final isToday   = dateKey == todayKey;

                        return CalDayCell(
                          dayNumber: date.day,
                          isWorkedOut: workedOut,
                          isToday: isToday,
                          onTap: workedOut
                              ? () => _showDayDetail(context, provider, dateKey)
                              : null,
                        );
                      },
                    ),

                    // Legend
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _legendDot(kGreen, kGreenDim),
                        const SizedBox(width: 6),
                        const Text('Workout done',
                            style: TextStyle(fontSize: 11, color: kTextMuted)),
                        const SizedBox(width: 16),
                        _legendDot(Colors.white, const Color(0xFF1A1A1A),
                            border: kGreen),
                        const SizedBox(width: 6),
                        const Text('Today',
                            style: TextStyle(fontSize: 11, color: kTextMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reset button
              Center(
                child: TextButton(
                  onPressed: () => _confirmReset(context, provider),
                  child: const Text(
                    'Reset all data',
                    style: TextStyle(color: kTextMuted, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color fg, Color bg, {Color? border}) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: border != null ? Border.all(color: border, width: 1.5) : null,
      ),
    );
  }

  void _showDayDetail(
      BuildContext context, GymProvider provider, String dateKey) {
    final log = provider.getLog(dateKey);
    if (log == null) return;
    final set  = provider.getSetById(log.workoutSetId);
    final date = DateTime.parse('${dateKey}T00:00:00');

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat('EEEE, MMMM d').format(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              if (set != null) ...[
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
                        set.name,
                        style: const TextStyle(
                            color: kGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${log.completedExerciseIds.length}/${set.exercises.length} done',
                      style:
                          const TextStyle(color: kTextMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF252525), height: 1),
                const SizedBox(height: 8),
                ...set.exercises.map((ex) {
                  final done =
                      log.completedExerciseIds.contains(ex.id);
                  final w = log.weights?[ex.id];
                  final weightLabel = w != null
                      ? (w % 1 == 0
                          ? '${w.toInt()} kg'
                          : '$w kg')
                      : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: done ? kGreen : const Color(0xFF3A3A3A),
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: done
                                      ? Colors.white
                                      : kTextMuted,
                                ),
                              ),
                              if (ex.meta.isNotEmpty)
                                Text(
                                  ex.meta,
                                  style: const TextStyle(
                                      fontSize: 11, color: kTextMuted),
                                ),
                            ],
                          ),
                        ),
                        if (weightLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kGreenDim,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              weightLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: kGreen,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ] else ...[
                const Text('Workout completed',
                    style: TextStyle(color: kTextMuted, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, GymProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Reset all data?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all workout history and sets. This cannot be undone.',
          style: TextStyle(color: kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.resetAll();
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
