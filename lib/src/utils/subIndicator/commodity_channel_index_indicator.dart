// Range = (-100~100)
import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';

class CommodityChannelIndexIndicator extends SubIndicator {
  CommodityChannelIndexIndicator({
    int periods = 10,
    required Color color,
    String? label,
  }) : super(
          name: label ?? "CCI $periods",
          chartStyle: SubIndicatorChartType.line0,
          dependsOnNPrevCandles: periods,
          calculatorWithStyle: (index, candles) {
            var c1 = candles[index].typicalPrice;
            var c2 = candles.hlcMovingAverage(periods, index: index);
            var c3 = candles.sum((p0, i) {
              var tmp = p0.typicalPrice;
              var tmp2 = candles.hlcMovingAverage(periods, index: i);
              return (tmp - tmp2).abs();
            }, periods: periods, index: index);

            return [
              ColorWithCalculatorValue()
                ..color = color
                ..value = ((c1 - c2) / c3) * 66.666666666666666666666,
              ColorWithCalculatorValue()
                ..color = color
                ..value = 100
                ..chartStyle = SubIndicatorChartType.dashLine,
              ColorWithCalculatorValue()
                ..color = color
                ..value = -100
                ..chartStyle = SubIndicatorChartType.dashLine,
              ColorWithCalculatorValue()
                ..color = color
                ..value = 0
                ..chartStyle = SubIndicatorChartType.line
            ];
          },
          max: (index, candles, c) {
            var f = (int index, List<Candle> candles) {
              var c1 = candles[index].typicalPrice;
              var c2 = candles.hlcMovingAverage(periods, index: index);
              var c3 = candles.sum((p0, i) {
                var tmp = p0.typicalPrice;
                var tmp2 = candles.hlcMovingAverage(periods, index: i);
                return (tmp - tmp2).abs();
              }, periods: periods, index: index);

              return ((c1 - c2) / c3) * 66.666666666666666666666;
            };
            List<num> resultList = [];
            c.forEach((element) {
              var index = candles.indexWhere((e) => e == element);
              resultList.add(f(index, candles));
            });
            if (resultList
                .every((element) => element < 100 && element > -100)) {
              return 100;
            } else if (resultList
                .every((element) => element < 200 && element > -200)) {
              return 200;
            } else {
              return 300;
            }
          },
          min: (i, candles, c2) {
            var f = (int index, List<Candle> candles) {
              var c1 = candles[index].typicalPrice;
              var c2 = candles.hlcMovingAverage(periods, index: index);
              var c3 = candles.sum((p0, i) {
                var tmp = p0.typicalPrice;
                var tmp2 = candles.hlcMovingAverage(periods, index: i);
                return (tmp - tmp2).abs();
              }, periods: periods, index: index);

              return ((c1 - c2) / c3) * 66.666666666666666666666;
            };
            List<num> resultList = [];
            c2.forEach((element) {
              var index = candles.indexWhere((e) => e == element);
              resultList.add(f(index, candles));
            });
            if (resultList
                .every((element) => element < 100 && element > -100)) {
              return -100;
            } else if (resultList
                .every((element) => element < 200 && element > -200)) {
              return -200;
            } else {
              return -300;
            }
          },
          calculator: (index, candles) {
            return [candles[index].volume];
          },
        );
}
