import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:json_annotation/json_annotation.dart';

import '../converters/color_converter.dart';

@JsonSerializable()
class WeightedMovingAverageIndicator extends Indicator {
  late String name;
  int length;

  @ColorConverter()
  Color color;
  String koreanName = "가중 이동 평균선";

  WeightedMovingAverageIndicator(
      {required int this.length, required Color this.color, String? label})
      : super(
            name: "WMA " + length.toString(),
            dependsOnNPrevCandles: length,
            calculator: (index, candles) {
              double sum = 0;
              for (int i = 0; i < length; i++) {
                sum += candles[i + index].close * (length - i);
              }
              return [sum / (length * (length + 1)) * 2];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "wmv", bullColor: color),
            ],
            label: label) {
    name = "WMA " + length.toString();
  }
}
