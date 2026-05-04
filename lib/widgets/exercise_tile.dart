import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../theme/app_theme.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool isChecked;
  final VoidCallback onTap;
  final double? weight;
  final ValueChanged<double?>? onWeightChanged;
  final bool locked;
  final double? previousWeight;

  const ExerciseTile({
    super.key,
    required this.exercise,
    required this.isChecked,
    required this.onTap,
    this.weight,
    this.onWeightChanged,
    this.locked = false,
    this.previousWeight,
  });

  void _showWeightDialog(BuildContext context) {
    final controller = TextEditingController(
      text: weight != null
          ? (weight! % 1 == 0
              ? weight!.toInt().toString()
              : weight!.toString())
          : '',
    );

    final prevLabel = previousWeight != null
        ? (previousWeight! % 1 == 0
            ? '${previousWeight!.toInt()} kg'
            : '$previousWeight kg')
        : null;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: Text(
          exercise.name,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prevLabel != null) ...[
              Text(
                'Last time: $prevLabel',
                style: const TextStyle(color: kTextMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                suffixText: 'kg',
                suffixStyle: TextStyle(color: kTextMuted),
                hintText: '0',
                hintStyle: TextStyle(color: kTextMuted),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3A3A3A)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kGreen),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              onWeightChanged?.call(null);
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear',
                style: TextStyle(color: kTextMuted, fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              onWeightChanged?.call(val != null && val > 0 ? val : null);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save',
                style: TextStyle(
                    color: kGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightLabel = weight != null
        ? (weight! % 1 == 0
            ? '${weight!.toInt()} kg'
            : '$weight kg')
        : '— kg';

    final prevLabel = previousWeight != null
        ? (previousWeight! % 1 == 0
            ? '${previousWeight!.toInt()} kg'
            : '$previousWeight kg')
        : null;

    return InkWell(
      onTap: locked ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? kGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? kGreen : const Color(0xFF3A3A3A),
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 13, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isChecked ? kTextMuted : kTextPrimary,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                      decorationColor: kTextMuted,
                    ),
                  ),
                  if (exercise.meta.isNotEmpty)
                    Text(
                      exercise.meta,
                      style: TextStyle(
                        fontSize: 11,
                        color: isChecked
                            ? const Color(0xFF333333)
                            : kTextMuted,
                      ),
                    ),
                  if (prevLabel != null && weight == null && !locked)
                    Text(
                      'prev: $prevLabel',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF3A5A3A),
                      ),
                    ),
                ],
              ),
            ),
            if (onWeightChanged != null)
              GestureDetector(
                onTap: locked ? null : () => _showWeightDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: weight != null
                        ? kGreenDim
                        : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    weightLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: locked
                          ? (weight != null ? kGreen : const Color(0xFF3A3A3A))
                          : (weight != null ? kGreen : kTextMuted),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
