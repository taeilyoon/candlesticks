import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';
import 'dart:math';

class OBVIndicator extends SubIndicator {
  OBVIndicator({
    int len = 2,
    required Color color,
    String? label,
  }) : super(
    chartStyle: SubIndicatorChartType.line0,
    name: label ?? "OBV ${len}",
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
