import 'package:flutter/material.dart';
import 'dart:math';

class PercentIndicatorPainter extends CustomPainter {
  final double percent;
  final double radius;
  final Color lineColor;
  final Color completeColor;
  final double width;

  PercentIndicatorPainter({
    required this.percent,
    required this.radius,
    required this.lineColor,
    required this.completeColor,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Paint complete = Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = max(20, this.radius);

    canvas.drawCircle(center, radius, line);

    double arcAngle = 2 * pi * (percent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      arcAngle,
      false,
      complete,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
