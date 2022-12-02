import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';

class MACDIndicatorIndicator extends SubIndicator {
  MACDIndicatorIndicator({
    int shortPeriod = 0,
    int longPeriod = 0,
    required Color color,
    String? label,
  }) : super(
            chartStyle: SubIndicatorChartType.line,
            name: label ?? "ADC ${shortPeriod}",
            dependsOnNPrevCandles: 0,
            calculator: (index, candles) {
              return [candles[index].volume];
            },
            calculatorWithStyle: (index, candles) {
              var shortValue = null;
              var longValue = null;

              if(candles.length - index -1>= shortPeriod) {
                var nc = candles.sublist( index, candles.length).map((e) => e.close as num).toList();
                shortValue = nc.exponentialMovingAverage(shortPeriod, index: index);
              }


              if(candles.length - index -1>= longPeriod) {
                var nc = candles.sublist( index, candles.length).map((e) => e.close as num).toList();
                longValue = nc.exponentialMovingAverage(longPeriod, index: index);
              }

              return [
                ColorWithCalculatorValue(
                    color: color,
                    value: shortValue != null && longValue != null ? shortValue - longValue : null)
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
