import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/utils/converters/color_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'moving_average_indicator.g.dart';
@JsonSerializable()
class MovingAverageIndicator extends Indicator {
  int length;
  @ColorConverter()
  Color color;
  String koreanName = "단순 이동 평균선";
  String name;


  MovingAverageIndicator(
      {required this.length, required Color this.color, String? label, required this.name,})
      : super(
            name: name,
            dependsOnNPrevCandles: length,
            calculator: (index, candles) {
              double sum = 0;
              for (int i = 0; i < length; i++) {
                sum += candles[i + index].close;
              }
              return [sum / length];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "이동평균선", bullColor: color),
            ],
            label: label
            ){

  }
  factory MovingAverageIndicator.fromJson(Map<String, dynamic> json) =>
      _$MovingAverageIndicatorFromJson(json);
  Map<String, dynamic> toJson() => _$MovingAverageIndicatorToJson(this);
}
