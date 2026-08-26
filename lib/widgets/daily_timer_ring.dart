import 'dart:math' as math;

import 'package:flutter/material.dart';

class DailyTimerRing extends StatelessWidget {
  final DateTime now;

  const DailyTimerRing({
    super.key,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: CustomPaint(
        painter: _DailyTimerRingPainter(
          now: now,
        ),
      ),
    );
  }
}

class _DailyTimerRingPainter extends CustomPainter {
  final DateTime now;

  static const int totalSegments = 15;

  _DailyTimerRingPainter({
    required this.now,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        math.min(size.width, size.height) / 2 - 3;

    final startHour = 6;
    final endHour = 21;

    final start = DateTime(
      now.year,
      now.month,
      now.day,
      startHour,
    );

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      endHour,
    );

    int elapsedHours;

    if (now.isBefore(start)) {
      elapsedHours = 0;
    } else if (!now.isBefore(end)) {
      elapsedHours = totalSegments;
    } else {
      elapsedHours =
          now.difference(start).inHours.clamp(
            0,
            totalSegments,
          );
    }

    const activeColor = Color(0xFF4FC3F7);
    const inactiveColor = Color(0xFF3A404B);

    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.square;

    const gap = 0.055;

    for (int i = 0; i < totalSegments; i++) {
      final segmentStart =
          -math.pi / 2 +
              (2 * math.pi / totalSegments) * i +
              gap;

      final segmentSweep =
          (2 * math.pi / totalSegments) -
              (gap * 2);

      segmentPaint.color =
      i < totalSegments - elapsedHours
          ? activeColor
          : inactiveColor;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        segmentStart,
        segmentSweep,
        false,
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      _DailyTimerRingPainter oldDelegate,
      ) {
    return oldDelegate.now.minute != now.minute ||
        oldDelegate.now.hour != now.hour ||
        oldDelegate.now.day != now.day;
  }
}