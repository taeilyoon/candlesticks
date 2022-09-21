import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';

class SimpleDrawIndicator extends Indicator {
  SimpleDrawIndicator({
    List<DateTime> dates = const [],
    List<double> values = const [],
    Color color = Colors.black,
    String name = "drawing",
    String label = "drawing",
  }) : super(
            name: name,
            dependsOnNPrevCandles: 0,
            calculator: (index, candles) {
              var curr = candles[index];
              var i = dates
                  .indexWhere((element) => element.compareTo(curr.date) == 0);
              if (i == -1) {
                return [null];
              } else {
                return [values[i]];
              }
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "upper", color: color),
            ],
            label: label);
}
