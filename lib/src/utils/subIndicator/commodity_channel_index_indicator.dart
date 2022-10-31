import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';

import '../../models/sub_indicator.dart';

//Range = (-100~100)
class CommodityChannelIndexIndicator extends SubIndicator {
  CommodityChannelIndexIndicator({
    int periods = 10,
    required Color color,
    String? label,
  }) : super(
            chartStyle: SubIndicatorChartType.line0,
            name: label ?? "CCI ${periods}",
            dependsOnNPrevCandles: periods * 2,
            calculator: (index, candles) {
              var c1 = candles[index].typicalPrice;
              var c2 = candles.hlcMovingAverage(periods, index: index);
              var c3 = candles.sum((p0, i) {
                var tmp = p0.typicalPrice;
                var tmp2 = candles.hlcMovingAverage(periods, index: i);
                return (tmp - tmp2).abs();
              }, periods: periods, index: index);

              return [((c1 - c2) / c3) * 66.666666666666666666666];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "cci", bullColor: color),
            ]);
}
