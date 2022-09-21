import 'dart:ui';

import 'package:candlesticks/src/utils/util.dart';
import 'package:flutter/material.dart';

class ChartDrawing {
  late final List<double> y;
  late final List<DateTime> x;
  late List<Color> borderColor;
  late List<Color> fillColor;
  late double? value;
  late DrawingType type;

  ChartDrawing({
    required this.x,
    required this.y,
    required this.borderColor,
    required this.fillColor,
    required this.type,
    this.value,
  });

  void drawing(
    Canvas canvas,
    double startX,
    double endY,
    double candleSize,
    double range,
  ) {
    switch (type) {
      case DrawingType.circle:
        canvas.drawCircle(
            Offset(startX, endY),
            this.value!,
            Paint()
              ..color = borderColor.firstOrNull ?? Colors.transparent
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke);
        canvas.drawCircle(Offset(startX, endY), this.value!,
            Paint()..color = fillColor.firstOrNull ?? Colors.black);

        break;
      case DrawingType.simpleSquare:
        canvas.drawRect(Offset(100, 100) & const Size(200, 150), Paint());
        break;
    }
  }
}

enum DrawingType { circle, simpleSquare, line, xline }
