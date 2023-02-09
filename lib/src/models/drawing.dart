import 'dart:ui';

import 'package:flutter/material.dart';

enum DrawingType {
  none,
  circle,
  simpleSquare,
  divideLine,
  line,
  xline,
  xlineNotInf,
  fibonacciRetracement
}

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

enum LineStyle {
  solid,
  dotted,
  dashed,
}

enum LineRange {
  open,
  close,
  startOpen,
  endOpen,
}

class LineDrawing extends ChartDrawing {
  late final DateTime startX;
  late final DateTime endX;

  late final double startY;
  late final double endY;
  late final Color color;
  late LineStyle style;
  late LineRange range;
  double? width;
  late String name;

  LineDrawing(
      {required this.startX,
      required this.endX,
      required this.startY,
      required this.endY,
      required this.color,
      required this.style,
      this.name = "line",
      this.width = 1.0,
      required this.range})
      : super(
            x: [startX, endX],
            y: [startY, endY],
            borderColor: [color],
            fillColor: [color],
            type: DrawingType.line,
            width: width,
            name: name,
            textSize: 16.0,
            textColor: Colors.black);
}

enum MarkerType {
  circle,
  diamond,
  square,
}

class MarkerDrawing extends ChartDrawing {
  late final DateTime X;
  late final double Y;
  late final Color color;
  late final double size;
  late final String name;
  late final MarkerType shape;

  MarkerDrawing(
      {required this.X,
      required this.Y,
      required this.color,
      required this.shape,
      required this.size,
      required this.name})
      : super(
            x: [X],
            y: [Y],
            borderColor: [color],
            fillColor: [color],
            type: DrawingType.circle,
            width: size,
            name: name,
            textSize: 16.0,
            textColor: Colors.black);
}

enum TextDrawingType { bubble, normal, bubbleArrow }

enum TextAnchor { top, bottom, center, left, right }

class TextDrawing extends ChartDrawing {
  TextDrawingType textType;
  TextAnchor anchor;
  String text;
  late final DateTime X;
  late final double Y;
  late final Color color;
  late final double size;

  TextDrawing({
    this.textType = TextDrawingType.normal,
    this.anchor = TextAnchor.center,
    required this.text,
    required this.X,
    required this.Y,
    this.color = Colors.black,
    this.size = 16,
  }) : super(
            x: [X],
            y: [Y],
            borderColor: [color],
            fillColor: [color],
            type: DrawingType.none,
            width: size,
            name: text,
            textSize: 16.0,
            textColor: Colors.black);
}
