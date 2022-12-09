import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:flutter/material.dart';

import '../../models/sub_indicator.dart';
import 'dart:math';

class ADXIndicator extends SubIndicator {
  ADXIndicator({
    int adxLen = 14,
    int diLen = 14,
    required Color color,
    String? label,
  }) : super(
            chartStyle: SubIndicatorChartType.line0,
            name: label ?? "ADX ${adxLen}",
            dependsOnNPrevCandles: adxLen * 2,
            calculator: (index, candles) {
              return [candles[index].volume];
            },
            calculatorWithStyle: (index, candles) {
                if (candles.length - index < 2) {
                  return [];
                }
                // DI+
                var left = (index) => candles.length - 2 < index
                    ? 0
                    : candles[index].high - candles[index + 1].high > 0 &&
                            candles[index].high - candles[index + 1].high >
                                candles[index + 1].low - candles[index].low
                        ? candles[index].high - candles[index + 1].high
                        : 0;

                var right = (index) => candles.length - 2 < index
                    ? 0
                    : (Math.Max(
                        Math.Max(
                            candles[index].high - candles[index].low,
                            Math.Abs(candles[index + 1].close -
                                candles[index].high)),
                        Math.Abs(
                            candles[index + 1].close - candles[index].low)));

                var DPleftList =
                    candles.map((e) => left(candles.indexOf(e))).toList();
                var DPrightList =
                    candles.map((e) => right(candles.indexOf(e))).toList();

                // DI-
                var mleft = (index) =>candles.length - 2 < index
                    ? 0
                    :
                (candles[index + 1].low - candles[index].low > 0 &&
                            candles[index].high - candles[index + 1].high <
                                candles[index + 1].low - candles[index].low
                        ? candles[index + 1].low - candles[index].low
                        : 0);
                var mright = (index) =>candles.length - 2 < index
                    ? 0
                    :  Math.Max(
                    Math.Max(
                        candles[index].high - candles[index].low,
                        Math.Abs(
                            candles[index + 1].close - candles[index].high)),
                    Math.Abs(candles[index + 1].close - candles[index].low));

                var DMleftList =
                    candles.map((e) => mleft(candles.indexOf(e))).toList();
                var DMrightList =
                    candles.map((e) => mright(candles.indexOf(e))).toList();

                var dpleftAvg = (index) =>
                    DPleftList.exponentialMovingAverage(adxLen, index: index);
                var dprightAvg = (index) =>
                    DPrightList.exponentialMovingAverage(adxLen, index: index);
                var dmleftAvg = (index) =>
                    DMleftList.exponentialMovingAverage(adxLen, index: index);
                var dmrightAvg = (index) =>
                    DMrightList.exponentialMovingAverage(adxLen, index: index);

                var diPlus =
                    (index) => dpleftAvg(index) / dprightAvg(index) * 100;
                var diMinus =
                    (index) => dmleftAvg(index) / dmrightAvg(index) * 100;

                var dx = (index) =>
                    Math.Abs(diPlus(index) - diMinus(index)) /
                    (diPlus(index) + diMinus(index)) *
                    100;

                if(candles.length > index+adxLen*2){
                  var adx = List.generate(adxLen+1, (i) => index+i)
                      .map((e) => dx(e))
                      .toList();

                  var adxList = adx.exponentialMovingAverage(adxLen, index: 0);
                  return [
                    ColorWithCalculatorValue(
                      color: Colors.yellow,
                      value: adxList.toDouble(),
                    ),
                  ];
                }else{
                  return [];
                }


            },
            max: (i, c, c2) {
              return 100;
            },
            min: (i, c, _) {
              return 0;
            },
            // indicatorComponentsStyles: [
            //   IndicatorStyle(name: "cci", bullColor: color),
            // ]
            );
}
