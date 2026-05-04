import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GymProgressBar extends StatelessWidget {
  final int done;
  final int total;

  const GymProgressBar({super.key, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$done / $total completed',
              style: const TextStyle(fontSize: 12, color: kTextMuted),
            ),
            Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: kTextMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: pct),
          duration: const Duration(milliseconds: 350),
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 5,
              backgroundColor: kSurface2,
              valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
            ),
          ),
        ),
      ],
    );
  }
}
