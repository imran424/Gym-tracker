import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout_set.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const _dayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<GymProvider>();
    final schedule  = provider.schedule;
    final sets      = provider.workoutSets;
    final todayIdx  = DateTime.now().weekday - 1; // 0=Mon

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap a day to change its workout.',
                style: TextStyle(fontSize: 13, color: kTextMuted),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: List.generate(7, (i) {
                    final setId  = schedule.dayAssignments[i];
                    final set    = provider.getSetById(setId);
                    final isToday = i == todayIdx;

                    return _DayRow(
                      dayName: _dayNames[i],
                      dayAbbr: _dayAbbr[i],
                      assignedSet: set,
                      isToday: isToday,
                      isLast: i == 6,
                      onTap: () => _showPickerSheet(
                          context, provider, sets, i, setId),
                    );
                  }),
                ),
              ),

              // Weekly summary chips
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (i) {
                  final setId = schedule.dayAssignments[i];
                  final set   = provider.getSetById(setId);
                  return _WeekChip(abbr: _dayAbbr[i], set: set);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickerSheet(
    BuildContext context,
    GymProvider provider,
    List<WorkoutSet> sets,
    int dayIndex,
    String? currentSetId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _dayNames[dayIndex],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: kBorder, height: 1),

            // Rest Day option
            ListTile(
              title: const Text('Rest Day',
                  style: TextStyle(color: kTextPrimary)),
              leading: Icon(
                currentSetId == null
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: currentSetId == null ? kGreen : kTextMuted,
                size: 20,
              ),
              onTap: () {
                provider.assignDay(dayIndex, null);
                Navigator.pop(context);
              },
            ),

            // Set options
            ...sets.map(
              (set) => ListTile(
                title: Text(set.name,
                    style: const TextStyle(color: kTextPrimary)),
                subtitle: Text(
                  '${set.exercises.length} exercises',
                  style: const TextStyle(color: kTextMuted, fontSize: 12),
                ),
                leading: Icon(
                  currentSetId == set.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: currentSetId == set.id ? kGreen : kTextMuted,
                  size: 20,
                ),
                onTap: () {
                  provider.assignDay(dayIndex, set.id);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String dayName;
  final String dayAbbr;
  final WorkoutSet? assignedSet;
  final bool isToday;
  final bool isLast;
  final VoidCallback onTap;

  const _DayRow({
    required this.dayName,
    required this.dayAbbr,
    required this.assignedSet,
    required this.isToday,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: dayAbbr == 'Mon' ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Day indicator
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isToday ? kGreen : kSurface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      dayAbbr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isToday ? Colors.black : kTextMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        assignedSet?.name ?? 'Rest Day',
                        style: TextStyle(
                          fontSize: 12,
                          color: assignedSet != null ? kGreen : kTextMuted,
                          fontWeight: assignedSet != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: kTextMuted, size: 18),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            color: Color(0xFF222222),
            height: 1,
            indent: 66,
          ),
      ],
    );
  }
}

class _WeekChip extends StatelessWidget {
  final String abbr;
  final WorkoutSet? set;

  const _WeekChip({required this.abbr, required this.set});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: set != null ? kGreenDim : kSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            abbr,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: kTextMuted),
          ),
          const SizedBox(height: 2),
          Text(
            set?.name.split(' ').first ?? '—',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: set != null ? kGreen : kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
