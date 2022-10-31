import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';

import '../../models/sub_indicator.dart';

//Range = (-100~100)
class VolumeIndicatorIndicator extends SubIndicator {
  VolumeIndicatorIndicator({
    int periods = 0,
    required Color color,
    String? label,
  }) : super(
            chartStyle: SubIndicatorChartType.line0,
            name: label ?? "CCI ${periods}",
            dependsOnNPrevCandles: periods * 2,
            calculator: (index, candles) {
              return [candles[index].volume];
            },
            calculatorWithStyle: (index, candles) {
              return [
                ColorWithCalculatorValue()
                  ..value = candles[index].volume
                  ..color = candles[index + 1].volume > candles[index].volume
                      ? color
                      : color
              ];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "cci", bullColor: color),
            ]);
}
