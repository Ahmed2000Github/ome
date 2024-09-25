import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ome/components/percent_indicator/percent_indicator_painter.dart';

class PercentIndicator extends StatefulWidget {
  final double percent;
  final double lineWidth;
  final double size;
  final Color lineColor;
  final Color completeColor;

  const PercentIndicator({
    Key? key,
    required this.percent,
    required this.lineWidth,
    required this.size,
    required this.lineColor,
    required this.completeColor,
  }) : super(key: key);

  @override
  _PercentIndicatorState createState() => _PercentIndicatorState();
}

class _PercentIndicatorState extends State<PercentIndicator> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: PercentIndicatorPainter(
        percent: widget.percent,
        radius: widget.size,
        lineColor: widget.lineColor,
        completeColor: widget.completeColor,
        width: widget.lineWidth,
      ),
      child: Center(
        child: Text(
          '${widget.percent.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: max(10, widget.size / 2),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
