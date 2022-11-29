import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/utils/converters/color_converter.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Indicator {
  /// Indicator name. visible at top right side of chart
  final String name;
  final String? label;
  bool visible = true;

  /// Calculates indicator value for givien index.
  /// if your indicator has muliple lines (values) always return results in the same order.
  @JsonKey(ignore: true)
  late List<double?> Function(int index, List<Candle> candles) calculator;
  final int dependsOnNPrevCandles;

  /// Indicator lines style.
  /// the order of this should be same as calculator function results order.
  final List<IndicatorStyle> indicatorComponentsStyles;
  final List<IndicatorStyle> indicatorFill;

  Indicator(
      {required this.name,
      required this.dependsOnNPrevCandles,
      List<double?> Function(int index, List<Candle> candles)? calculator,
      required this.indicatorComponentsStyles,
      this.indicatorFill = const [],
      this.label}) {
    if (calculator == null) {
      this.calculator = (int i, List<Candle> c) {
        return <double>[];
      };
    } else {
      this.calculator = calculator;
    }
  }

  bool operator ==(other) {
    try {
      if (other is Indicator) {
        var s = other.indicatorComponentsStyles
            .asMap()
            .map((key, value) {
              return MapEntry(
                  key,
                  this.indicatorComponentsStyles[key].bullColor ==
                      value.bullColor);
            })
            .values
            .every((element) => element);
        return other.name == this.name && s;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

@JsonSerializable()
class IndicatorFill {
  IndicatorStyle style;
  int fillFirst;
  int fillSecond;

  IndicatorFill({
    required this.style,
    required this.fillFirst,
    required this.fillSecond,
  });
}

@JsonSerializable()
class IndicatorStyle {
  String name;
  @ColorConverter()
  Color bullColor;
  @ColorConverter()
  Color? bearColor;
  int? startIndex;
  int? endIndex;
  IndicatorStyle(
      {required this.name,
      required this.bullColor,
      this.bearColor,
      this.startIndex,
      this.endIndex});
}
