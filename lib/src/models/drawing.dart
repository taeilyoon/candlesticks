import 'dart:ui';

import 'package:flutter/material.dart';

class ChartDrawing {
  late final List<double> y;
  late final List<DateTime> x;
  late List<Color> borderColor;
  late List<Color> fillColor;
  late double? width;
  late DrawingType type;
  late String name = "";

  ChartDrawing({
    required this.x,
    required this.y,
    required this.borderColor,
    required this.fillColor,
    required this.type,
    this.width,
  });
}

enum DrawingType {
  none,
  circle,
  simpleSquare,
  divideLine,
  line,
  xline,
  fibonacciRetracement
}
