import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';

class MACDIndicator extends SubIndicator {
  MACDIndicator({
    int shortPeriod = 12,
    int longPeriod = 26,
    int signalPeriod = 9,
    Color color = Colors.red,
    Color color2 = Colors.blue,
    String? label,
  }) : super(
            chartStyle: SubIndicatorChartType.stick,
            name: label ?? "ADC ${shortPeriod}",
            dependsOnNPrevCandles: 0,
            calculator: (index, candles) {
              return [candles[index].volume];
            },
            calculatorWithStyle: (index, candles) {
              var getprivate = (index){
                var short =candles.map((e) => e.close).toList().exponentialMovingAverage(shortPeriod, index:  index);
                var long  =candles.map((e) => e.close).toList().exponentialMovingAverage(longPeriod, index : index);
                var macd = short - long;
                return macd;
              };


              if(candles.length > longPeriod+signalPeriod +index ){

                var signal = List.generate(signalPeriod+1, (i) => i + index).map((e) => getprivate(e)).toList()
                    .exponentialMovingAverage(signalPeriod, index: 0);
                var macd = getprivate(index);

                return [
                  ColorWithCalculatorValue(
                    color: (macd - signal).isNegative ? color2 :color,
                    value: (macd - signal).toDouble(),
                  ),
                ];
              }else{
                return [
                  ColorWithCalculatorValue(
                    color: color,
                    value: 0,
                  ),
                ];
              }
            },
            max: (i, c, c2) {
              return c2.map((e) => e.map((e) => e?.value ??0).toList().reduce((value, element) => Math.Max(value, element))).toList().max();
            },
            min: (i, c, c2) {
              return c2.map((e) => e.map((e) => e?.value ??0).toList().reduce((value, element) => [value, element].min())).toList().min();
            }
            // indicatorComponentsStyles: [
            //   IndicatorStyle(name: "cci", bullColor: color),
            // ]
            );
}
