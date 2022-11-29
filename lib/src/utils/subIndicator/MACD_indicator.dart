import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';

class MACDIndicatorIndicator extends SubIndicator {
  MACDIndicatorIndicator({
    int periods = 0,
    required Color color,
    String? label,
  }) : super(
            chartStyle: SubIndicatorChartType.line,
            name: label ?? "ADC ${periods}",
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
                  ..color = candles[index + 1].volume > candles[index].volume
                      ? Colors.red
                      : Colors.blue
              ];
            },
            max: (i, c, c2) {
              return c2.map((e) => e.volume).toList().max();
            },
            min: (i, c, _) {
              return 0;
            }
            // indicatorComponentsStyles: [
            //   IndicatorStyle(name: "cci", bullColor: color),
            // ]
            );
}
