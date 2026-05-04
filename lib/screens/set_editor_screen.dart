import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';

class SetEditorScreen extends StatefulWidget {
  final String setId;
  const SetEditorScreen({super.key, required this.setId});

  @override
  State<SetEditorScreen> createState() => _SetEditorScreenState();
}

class _SetEditorScreenState extends State<SetEditorScreen> {
  late final TextEditingController _nameCtrl;
  final _exNameCtrl = TextEditingController();
  final _exMetaCtrl = TextEditingController();
  final _exNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final set =
        context.read<GymProvider>().getSetById(widget.setId);
    _nameCtrl = TextEditingController(text: set?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _exNameCtrl.dispose();
    _exMetaCtrl.dispose();
    _exNameFocus.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    context.read<GymProvider>().renameWorkoutSet(widget.setId, name);
  }

  void _addExercise() {
    final name = _exNameCtrl.text.trim();
    if (name.isEmpty) return;
    context.read<GymProvider>().addExerciseToSet(
          widget.setId,
          name,
          _exMetaCtrl.text.trim(),
        );
    _exNameCtrl.clear();
    _exMetaCtrl.clear();
    _exNameFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final set = context.watch<GymProvider>().getSetById(widget.setId);
    if (set == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => Navigator.pop(context));
      return const Scaffold(backgroundColor: kBg);
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Edit Set'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Name field ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: 'Set name',
                prefixIcon: Icon(Icons.edit, size: 16, color: kTextMuted),
              ),
              onEditingComplete: _saveName,
              onTapOutside: (_) => _saveName(),
              textInputAction: TextInputAction.done,
            ),
          ),

          // ── Exercise count label ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  '${set.exercises.length} exercises',
                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                ),
                const SizedBox(width: 6),
                const Text(
                  '· drag to reorder',
                  style: TextStyle(fontSize: 12, color: kTextMuted),
                ),
              ],
            ),
          ),

          // ── Reorderable exercise list ─────────────────────────────────────
          Expanded(
            child: set.exercises.isEmpty
                ? const Center(
                    child: Text(
                      'No exercises yet.\nAdd one below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kTextMuted, fontSize: 13, height: 1.6),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onReorder: (oldIndex, newIndex) => context
                        .read<GymProvider>()
                        .reorderExercises(widget.setId, oldIndex, newIndex),
                    itemCount: set.exercises.length,
                    itemBuilder: (_, i) {
                      final ex = set.exercises[i];
                      return Container(
                        key: ValueKey(ex.id),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.drag_handle,
                                color: kTextMuted, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: kTextPrimary,
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
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 16, color: kTextMuted),
                              onPressed: () => context
                                  .read<GymProvider>()
                                  .removeExerciseFromSet(
                                      widget.setId, ex.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ── Add exercise form ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            decoration: const BoxDecoration(
              color: kSurface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _exNameCtrl,
                      focusNode: _exNameFocus,
                      style: const TextStyle(
                          color: kTextPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                          hintText: 'Exercise name'),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _exMetaCtrl,
                      style: const TextStyle(
                          color: kTextPrimary, fontSize: 13),
                      decoration:
                          const InputDecoration(hintText: '3×10'),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addExercise(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addExercise,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
