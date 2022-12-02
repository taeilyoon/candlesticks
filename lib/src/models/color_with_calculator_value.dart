import 'dart:ui';

import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

class ColorWithCalculatorValue {
  double? value;
  double? value2;
  late Color color;
  late SubIndicatorChartType chartStyle;

  ColorWithCalculatorValue({
    this.value,
    this.value2,
    this.color = Colors.black,
    this.chartStyle = SubIndicatorChartType.line0,
  });
}
