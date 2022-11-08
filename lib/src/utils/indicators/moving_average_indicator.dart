import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';

class MovingAverageIndicator extends Indicator {
  MovingAverageIndicator(
      {required int length, required Color color, String? label, String? name})
      : super(
            name: name ?? "MA " + length.toString(),
            dependsOnNPrevCandles: length,
            calculator: (index, candles) {
              double sum = 0;
              for (int i = 0; i < length; i++) {
                sum += candles[i + index].close;
              }
              return [sum / length];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "mv", bullColor: color),
            ],
            label: label);
}
