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
      width: 46,
      height: 46,
      child: CustomPaint(
        painter: _DailyTimerRingPainter(now),
      ),
    );
  }
}

class _DailyTimerRingPainter extends CustomPainter {
  final DateTime now;

  static const int totalSegments = 15;

  const _DailyTimerRingPainter(this.now);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    /*
     * Position of the bars from the centre.
     */
    final radius =
        math.min(size.width, size.height) / 2 - 7;

    /*
     * Daily quest window:
     *
     * 06:00 AM → 09:00 PM
     */
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      6,
      0,
    );

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      21,
      0,
    );

    int elapsedHours = 0;

    if (now.isBefore(start)) {
      elapsedHours = 0;
    } else if (!now.isBefore(end)) {
      elapsedHours = totalSegments;
    } else {
      elapsedHours = now
          .difference(start)
          .inHours
          .clamp(0, totalSegments);
    }

    /*
     * Reference-style bars:
     *
     * - short
     * - rectangular
     * - slightly rounded
     * - clearly separated
     */
    const double barWidth = 3.0;
    const double barHeight = 8.0;
    const double cornerRadius = 1.5;

    final activePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final inactivePaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.fill;

    /*
     * One bar every 24 degrees.
     *
     * The first bar starts at the top.
     */
    const double angleStep =
        (2 * math.pi) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      final angle =
          -math.pi / 2 + (i * angleStep);

      /*
       * Centre position of this bar.
       */
      final barCenter = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      /*
       * Draw the rectangle around its own local origin.
       *
       * The rectangle is radial:
       * its LONG side points toward the centre/outward.
       */
      canvas.save();

      canvas.translate(
        barCenter.dx,
        barCenter.dy,
      );

      /*
       * Rotate so the long side of the bar
       * follows the radius.
       */
      canvas.rotate(angle + math.pi / 2);

      final barRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(
          cornerRadius,
        ),
      );

      /*
       * Bars are consumed clockwise as each hour passes.
       */
      final paint =
      i < totalSegments - elapsedHours
          ? activePaint
          : inactivePaint;

      canvas.drawRRect(
        barRect,
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
      covariant _DailyTimerRingPainter oldDelegate,
      ) {
    return oldDelegate.now.year != now.year ||
        oldDelegate.now.month != now.month ||
        oldDelegate.now.day != now.day ||
        oldDelegate.now.hour != now.hour;
  }
}