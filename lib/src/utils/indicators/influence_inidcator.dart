import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../converters/color_converter.dart';

part 'influence_inidcator.g.dart';

@JsonSerializable()
class InfurenceIndicator extends Indicator {
  String koreanName = "세력차트";

  int shortPeriod;
  int midPeriod;
  @ColorConverter()
  Color centerColor;
  @ColorConverter()
  Color centerChange;
  String name;

  InfurenceIndicator(
      {required int this.shortPeriod,
      required int this.midPeriod,
      Color this.centerColor = Colors.blue,
      Color this.centerChange = Colors.red,
      String? label,
      String this.name = "세력 중심선"})
      : super(
            name: name,
            dependsOnNPrevCandles: midPeriod,
            calculator: (index, candles) {
              var change = null;
              var standard = null;
              var before = null;
              var infCenter = null;
              var infChange = null;

              if (candles.length >= shortPeriod + index) {
                var range = candles.sublist(index, index + shortPeriod);

                var high = range.map((x) => x.high).toList().max();
                var low = range.map((x) => x.low).toList().min();

                change = (high + low) / 2;
              }

              if (candles.length >= midPeriod + index) {
                var range = candles.sublist(index, index + midPeriod);

                var high = range.map((x) => x.high).toList().max();
                var low = range.map((x) => x.low).toList().min();

                change = (high + low) / 2;
              }

              if (index > (midPeriod + 1))
                before = candles[index - midPeriod - 1].close;

              // 세력중심선
              if (candles.length >= shortPeriod + index) {
                var lowest = candles
                    .sublist(index, index + shortPeriod)
                    .map((x) => x.low)
                    .toList()
                    .min();
                var hignest = candles
                    .sublist(index, index + shortPeriod)
                    .map((x) => x.high)
                    .toList()
                    .max();

                infCenter = lowest + (hignest - lowest) * 0.618;
              }
              // 세력중심선
              if (candles.length >= shortPeriod + index + 1) {
                var lowest = candles
                    .sublist(index + 1, index + shortPeriod)
                    .map((e) => e.low)
                    .toList()
                    .min();
                var hignest = candles
                    .sublist(index + 1, index + shortPeriod)
                    .map((e) => e.high)
                    .toList()
                    .max();

                infChange = candles[index].close >
                        (lowest + ((hignest - lowest) * 0.618))
                    ? candles[index].high
                    : candles[index].low;
              }

              return [infCenter, infChange];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "세력 중심선", bullColor: centerColor),
              IndicatorStyle(name: "세력 전환선", bullColor: centerChange),
            ],
            indicatorFill: [
              IndicatorStyle(
                  name: "cloud1",
                  bullColor: centerChange.withOpacity(0.3),
                  bearColor: centerColor.withOpacity(0.3),
                  startIndex: 0,
                  endIndex: 1),
            ],
            label: label);

  factory InfurenceIndicator.fromJson(Map<String, dynamic> json) => _$InfurenceIndicatorFromJson(json);
  Map<String, dynamic> toJson() => _$InfurenceIndicatorToJson(this);
}
