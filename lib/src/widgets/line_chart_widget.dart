import 'package:candlesticks/src/models/drawing.dart';
import 'package:candlesticks/src/models/main_window_indicator.dart';
import 'package:flutter/material.dart';

import '../../candlesticks.dart';

class LineChartWidget extends LeafRenderObjectWidget {
  final List<Candle> candles;
  final int index;
  final double barWidth;
  final double bull;
  final double bear;
  final Color bullColor;
  final Color bearColor;
  final List<ChartDrawing> drawing;

  List<IndicatorComponentData> indicatorComponentData = [];
  List<Indicator> indicators;
  List<double> highs = [];
  List<double> lows = [];
  List<String> unvisibleIndicators = [];
  late DateTime beginDate;
  late DateTime endDate;

  LineChartWidget(
      {required this.candles,
      required this.index,
      required this.barWidth,
      required this.highs,
      required this.lows,
      required this.bull,
      required this.bear,
      required this.bullColor,
      required this.bearColor,
      required this.indicators,
      required this.unvisibleIndicators,
      this.drawing = const []}) {
    endDate = candles[0].endDate;
    beginDate = candles.last.endDate;
    indicators.forEach((indicator) {
      indicator.indicatorComponentsStyles.forEach((indicatorComponent) {
        indicatorComponentData.add(IndicatorComponentData(
            indicator, indicatorComponent.name, indicatorComponent.bullColor));
      });
    });

    indicators.forEach((indicator) {
      final List<IndicatorComponentData> containers = indicatorComponentData
          .where((element) => element.parentIndicator == indicator)
          .toList();

      print("s");
      for (int i = 0; i < candles.length; i++) {
        List<double?> indicatorDatas = List.generate(
            indicator.indicatorComponentsStyles.length, (index) => null);

        if (i + indicator.dependsOnNPrevCandles < candles.length) {
          indicatorDatas = indicator.calculator(i, candles);
        }

        for (int i = 0; i < indicatorDatas.length; i++) {
          containers[i].values.add(indicatorDatas[i]);
          if (indicatorDatas[i] != null) {
            // lows[i] = min(candles[i].low, indicatorDatas[i]!);
            // highs[i] = max(candles[i].high, indicatorDatas[i]!);
          }
        }
      }
      print(indicators);
    });
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return LineChartRenderObject(
        this.candles,
        this.index,
        this.barWidth,
        this.highs,
        this.lows,
        this.bull,
        this.bear,
        this.bullColor,
        this.bearColor,
        this.indicatorComponentData,
        this.drawing);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    LineChartRenderObject candlestickRenderObject =
        renderObject as LineChartRenderObject;
    candlestickRenderObject.candles = candles;
    candlestickRenderObject.index = index;
    candlestickRenderObject.barWidth = barWidth;
    candlestickRenderObject.highs = highs;
    candlestickRenderObject.lows = lows;
    candlestickRenderObject.bearColor = bearColor;
    candlestickRenderObject.bullColor = bullColor;
    candlestickRenderObject.markNeedsPaint();
    super.updateRenderObject(context, renderObject);
  }
}

class LineChartRenderObject extends RenderBox {
  late List<Candle> candles;
  late int index;
  late double barWidth;
  late List<double> highs;
  late List<double> lows;
  late double bull;
  late double bear;
  late Color bullColor;
  late Color bearColor;
  late List<IndicatorComponentData> indicators;
  final List<ChartDrawing> drawing;

  LineChartRenderObject(
      this.candles,
      this.index,
      this.barWidth,
      this.highs,
      this.lows,
      this.bull,
      this.bear,
      this.bullColor,
      this.bearColor,
      this.indicators,
      this.drawing);

  /// set size as large as possible
  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    indicators.forEach((element) {
      double range = size.height / (highs[0] - lows[0]);
      Path? path;

      for (int i = 0; (i + 1) * barWidth < size.width; i++) {
        if (i + index >= candles.length ||
            i + index < 0 ||
            element.values[i + index] == null) {
          continue;
        }
        if (path == null) {
          path = Path()
            ..moveTo(size.width + offset.dx - (i + 0.5) * barWidth,
                offset.dy + ((highs[0]) - element.values[i + index]!) * range);
        } else {
          path.lineTo(size.width + offset.dx - (i + 0.5) * barWidth,
              offset.dy + (highs[0] - element.values[i + index]!) * range);
        }
      }
      if (path != null)
        context.canvas.drawPath(
            path,
            Paint()
              ..color = element.color
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke);
    });

    context.canvas.save();
    context.canvas.restore();
  }
}
