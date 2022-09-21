import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';

//Range = (-100~100)
class CommodityChannelIndexIndicator extends Indicator {
  CommodityChannelIndexIndicator({
    int periods = 10,
    required Color color,
    String? label,
  }) : super(
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
              IndicatorStyle(name: "cci", color: color),
            ]);
}
