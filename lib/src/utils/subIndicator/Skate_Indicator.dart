import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';
import 'dart:math';

class SkateIndicator extends SubIndicator {
  SkateIndicator({
    int len = 2,
    int beginPeriod = 9,
    int judgePeriod = 26,
    int pointPeriod = 26,

    required Color color,
    String? label,
  }) : super(
    chartStyle: SubIndicatorChartType.line0,
    name: label ?? "RSI ${len}",
    dependsOnNPrevCandles: len,
    calculator: (index, candles) {
      return [candles[index].volume];
    },
    calculatorWithStyle: (index, candles) {
      // var getprivateMacd = (index, {shortPeriod = 9, longPeriod = 26}) {
      //   var short =candles.map((e) => e.close).toList().exponentialMovingAverage(shortPeriod, index:  index);
      //   var long  =candles.map((e) => e.close).toList().exponentialMovingAverage(longPeriod, index : index);
      //   var macd = short - long;
      //   return macd;
      // };
      // var privateSkate = (index){
      //   var macd  = getprivateMacd(index, shortPeriod: beginPeriod, longPeriod: judgePeriod);
      //
      //   if (index >= (judgePeriod - 1) + (pointPeriod / 3) - 1)
      //   {
      //     var range = macd(judgePeriod - 1, i - (judgePeriod - 2));
      //     double eavg = ExponentialMovingAverage(range, pointPeriod / 3);
      //   }
      // };
return [];

    },
    max: (i, c, c2) {
      var ls = [0.0];
      c2.map((e) => e.map((e) => e!.value ?? 0.0)).forEach((element) {
        ls.addAll(element);
      });
      return ls.max();


    },
    min: (i, c, c2) {
      var ls = <double>[];
      c2.map((e) => e.map((e) => e!.value!).where((element) => element != null)).forEach((element) {
        ls.addAll(element);
      });
      return ls.min();
    },
    // indicatorComponentsStyles: [
    //   IndicatorStyle(name: "cci", bullColor: color),
    // ]
  );
}
