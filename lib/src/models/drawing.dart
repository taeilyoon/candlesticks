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
  double? textSize;
  Color? textColor;
  ChartDrawing(
      {required this.x,
      required this.y,
      required this.borderColor,
      required this.fillColor,
      required this.type,
      this.width,
      String this.name = "",
      this.textSize = 16.0,
      this.textColor = Colors.black});
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
