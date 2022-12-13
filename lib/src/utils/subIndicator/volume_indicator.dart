import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';

//Range = (-100~100)
class VolumeIndicatorIndicator extends SubIndicator {
  VolumeIndicatorIndicator({
    int periods = 0,
    required Color color,
    String? label,
  }) : super(
            chartStyle: SubIndicatorChartType.stick,
            name: label ?? "거래량 ${periods}",
            dependsOnNPrevCandles: periods * 2,
            calculator: (index, candles) {
              return [candles[index].volume];
            },
            calculatorWithStyle: (index, candles) {
              if (index == candles.length - 1) {
                return [
                  ColorWithCalculatorValue()
                    ..value = candles[index].volume
                    ..color = color
                ];
              }
              return [
                ColorWithCalculatorValue()
                  ..value = candles[index].volume
                  ..color = candles[index + 1].volume < candles[index].volume
                      ? Colors.red
                      : Colors.blue
              ];
            },
            max: (i, c, c2, start, end) {
              return c2.sublist(start,end).map((e) => e.map((e) => e?.value ??0).toList().reduce((value, element) => Math.Max(value, element))).toList().max();
            },
            min: (i, c, _, start, end) {
              return 0;
            }
            // indicatorComponentsStyles: [
            //   IndicatorStyle(name: "cci", bullColor: color),
            // ]
            );
}
