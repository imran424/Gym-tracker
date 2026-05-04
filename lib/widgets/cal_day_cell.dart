import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalDayCell extends StatelessWidget {
  final int dayNumber;
  final bool isWorkedOut;
  final bool isToday;
  final VoidCallback? onTap;

  const CalDayCell({
    super.key,
    required this.dayNumber,
    required this.isWorkedOut,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFF1A1A1A);
    Color fg = const Color(0xFF3A3A3A);
    Border? border;

    if (isWorkedOut) {
      bg = kGreenDim;
      fg = kGreen;
    }
    if (isToday && !isWorkedOut) {
      border = Border.all(color: kGreen, width: 2);
      fg = Colors.white;
      bg = const Color(0xFF1A1A1A);
    }
    if (isToday && isWorkedOut) {
      bg = kGreen;
      fg = Colors.black;
      border = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: border,
          ),
          child: Center(
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
