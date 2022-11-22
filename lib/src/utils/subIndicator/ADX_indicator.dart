import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';
import 'dart:math';

class ADXIndicatorIndicator extends SubIndicator {
  ADXIndicatorIndicator({
    int periods = 1,
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
        var trueRange = max(
            max(
                candles[index].high - candles[index].low,
                (candles[index].high - nz(candles[index + 1].close))
                    .abs()),
            (candles[index].low - nz(candles[index + 1].close)).abs());

        var directionalMovementPlus = candles[index].high -
            nz(candles[index + 1].high) >
            nz(candles[index + 1].low) - candles[index].low ? max(
            candles[index].high - nz(candles[index + 1].high), 0) : 0;
        var directionalMovementMinus = nz(candles[index+1].low) - candles[index].low > candles[index].high - nz(candles[index+1].high)
            ? max(nz(candles[index+1].low) - candles[index].low, 0)
            : 0;




        var plusm = candles[index].high - candles[index + 1].high;
        var minusm = candles[index + 1].low - candles[index].low;

        if (plusm > minusm) {}
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
