import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout_set.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import 'set_editor_screen.dart';

class SetsScreen extends StatelessWidget {
  const SetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sets = context.watch<GymProvider>().workoutSets;

    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Workout Sets',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            if (sets.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fitness_center, size: 48, color: kTextMuted),
                      SizedBox(height: 12),
                      Text(
                        'No workout sets yet.',
                        style: TextStyle(color: kTextMuted, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap + to create one.',
                        style: TextStyle(color: kTextMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: sets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _SetCard(set: sets[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('New Workout Set',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: kTextPrimary),
          decoration: const InputDecoration(hintText: 'e.g. Push Day'),
          onSubmitted: (_) => _submit(ctx, ctrl),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _submit(ctx, ctrl),
              child: const Text('Create')),
        ],
      ),
    );
  }

  void _submit(BuildContext context, TextEditingController ctrl) {
    final name = ctrl.text.trim();
    if (name.isEmpty) return;
    context.read<GymProvider>().addWorkoutSet(name);
    Navigator.pop(context);

    // Navigate to editor
    final sets = context.read<GymProvider>().workoutSets;
    final newSet = sets.lastWhere((s) => s.name == name);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SetEditorScreen(setId: newSet.id)),
    );
  }
}

class _SetCard extends StatelessWidget {
  final WorkoutSet set;
  const _SetCard({required this.set});

  @override
  Widget build(BuildContext context) {
    final preview = set.exercises.take(3).map((e) => e.name).join(', ');
    final more = set.exercises.length > 3
        ? ' +${set.exercises.length - 3} more'
        : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SetEditorScreen(setId: set.id)),
      ),
      onLongPress: () => _confirmDelete(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${set.exercises.length} exercises',
                    style: const TextStyle(fontSize: 12, color: kGreen),
                  ),
                  if (set.exercises.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      preview + more,
                      style: const TextStyle(fontSize: 12, color: kTextMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextMuted),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSurface,
        title: Text('Delete "${set.name}"?',
            style: const TextStyle(color: Colors.white)),
        content: const Text('This will remove the set and unschedule it.',
            style: TextStyle(color: kTextMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<GymProvider>().deleteWorkoutSet(set.id);
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
