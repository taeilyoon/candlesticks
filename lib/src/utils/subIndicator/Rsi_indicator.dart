import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';
// part 'rsi_indicator.g.dart';
class RsiIndicator extends SubIndicator {
  int len;
  Color color;

  RsiIndicator({
    int this.len = 2,
    required Color this.color,
    String? label,
  }) : super(
    chartStyle: SubIndicatorChartType.line0,
    name: label ?? "RSI ${len}",
    dependsOnNPrevCandles: len,
    calculator: (index, candles) {
      return [candles[index].volume];
    },
    calculatorWithStyle: (index, candles) {

      var result =0.0;
      if(!(candles.length-1 -index).isNegative){
        for(int i in List.generate(candles.length-1 -index, (index) => index)){
          if(candles[index+i].close<candles[index+i+1].close){
            result -= candles[index+i].volume;
          }else if(candles[index+i].close>candles[index+i+1].close){
            result += candles[index+i].volume;
          }
        }
      };
      return [
        ColorWithCalculatorValue(
          color: Colors.yellow,
          value: result.toDouble(),
        ),
      ];

    },
    max: (i, c, c2, start, end) {
      var ls = [0.0];
      c2.sublist(start, end).map((e) => e.map((e) => e!.value ?? 0.0)).forEach((element) {
        ls.addAll(element);
      });
      return ls.max();


    },
    min: (i, c, c2, start, end) {
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
