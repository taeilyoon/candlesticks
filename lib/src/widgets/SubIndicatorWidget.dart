import 'package:candlesticks/src/models/drawing.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';
import 'package:candlesticks/src/models/sub_indicator.dart';
import 'package:flutter/material.dart';

import '../../candlesticks.dart';
import '../models/sub_window_indicator.dart';

class SubIndicatorWidget extends StatelessWidget {
  final List<Candle> candles;
  final int index;
  final double barWidth;
  final List<ChartDrawing> drawing;

  SubIndicator indicator;
  num high;
  num low;
  late DateTime beginDate;
  late DateTime endDate;

  SubIndicatorDataContainer indicatorData;
  List<SubIndicatorComponentData> indicatorDatas;

  Function(int i) onSetting;

  SubIndicatorWidget({
    required this.candles,
    required this.indicatorData,
    required this.index,
    required this.barWidth,
    required this.high,
    required this.low,
    required this.indicator,
    this.drawing = const [],
    required List<SubIndicatorComponentData> this.indicatorDatas,
    required this.onSetting,
  }) {
    endDate = candles[0].endDate;
    beginDate = candles.last.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            child: IconButton(
          icon: Icon(Icons.settings),
          onPressed: (){
            onSetting(this.indicatorData.subIndicators.indexWhere((element) => element == this.indicator));
          },
        )),
        Container(
          child: SubIndicatorWidgetCanvas(
              candles: candles,
              indicatorData: indicatorData,
              index: index,
              barWidth: barWidth,
              high: high,
              low: low,
              indicator: indicator,
              indicatorDatas: indicatorDatas),
        ),
      ],
    );
  }
}

class SubIndicatorWidgetCanvas extends LeafRenderObjectWidget {
  final List<Candle> candles;
  final int index;
  final double barWidth;
  final List<ChartDrawing> drawing;

  SubIndicator indicator;
  num high;
  num low;
  late DateTime beginDate;
  late DateTime endDate;

  SubIndicatorDataContainer indicatorData;
  List<SubIndicatorComponentData> indicatorDatas;

  SubIndicatorWidgetCanvas(
      {required this.candles,
      required this.indicatorData,
      required this.index,
      required this.barWidth,
      required this.high,
      required this.low,
      required this.indicator,
      this.drawing = const [],
      required List<SubIndicatorComponentData> this.indicatorDatas}) {
    endDate = candles[0].endDate;
    beginDate = candles.last.endDate;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return LineChartRenderObject(this.candles, this.index, this.barWidth,
        this.high, this.low, this.drawing, indicatorData, indicatorDatas);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    LineChartRenderObject candlestickRenderObject =
        renderObject as LineChartRenderObject;
    candlestickRenderObject.candles = candles;
    candlestickRenderObject.index = index;
    candlestickRenderObject.barWidth = barWidth;
    candlestickRenderObject.high = high;
    candlestickRenderObject.low = low;
    candlestickRenderObject.indicator = indicator;
    candlestickRenderObject.indicatorData = indicatorData;
    candlestickRenderObject.markNeedsPaint();
    super.updateRenderObject(context, renderObject);
  }
}

class LineChartRenderObject extends RenderBox {
  late List<Candle> candles;
  late int index;
  late double barWidth;
  late num high;
  late num low;
  late double bull;
  late double bear;
  late Color bullColor;
  late Color bearColor;
  final List<ChartDrawing> drawing;
  late SubIndicator indicator;

  SubIndicatorDataContainer indicatorData;

  List<SubIndicatorComponentData> indicatorDatas;

  LineChartRenderObject(
    this.candles,
    this.index,
    this.barWidth,
    this.high,
    this.low,
    this.drawing,
    this.indicatorData,
    List<SubIndicatorComponentData> this.indicatorDatas,
  );

  /// set size as large as possible

  void paintBar(PaintingContext context, Offset offset, int index, double value,
      double range, Color color) {
    double x = size.width + offset.dx - (index + 0.5) * barWidth;

    Offset(
        x,
        offset.dy +
            size.height -
            ((high - low - value) / ((high - low) / size.height)));
    Offset(
        x, offset.dy + size.height - ((-low) / ((high - low) / size.height)));
    context.canvas.drawLine(
        Offset(x,
            offset.dy + (size.height * (1 - ((value - low) / (high - low))))),
        Offset(x, offset.dy + (size.height * (1 - (-low / (high - low))))),
        Paint()
          ..color = color
          ..strokeWidth = barWidth - 1);
  }

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    double range = (high) / size.height;
    var targetIndicator = indicatorDatas[0];

    for (int li = 0; li < targetIndicator.values.first.length; li++) {
      Path? path;

      for (int i = 0; (i + 1) * barWidth < size.width; i++) {
        if (i + index >= candles.length || i + index < 0) continue;

        var value =
            targetIndicator.values[i + index].reversed.toList()[li]!.value ??
                0.0;

        context.canvas.drawPath(
            Path()
              ..moveTo(offset.dx,
                  offset.dy + (size.height * (1 - (-low / (high - low)))))
              ..lineTo(offset.dx + size.width,
                  offset.dy + (size.height * (1 - (-low / (high - low))))),
            Paint()
              ..color = Colors.grey
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke);
        switch (targetIndicator.parentIndicator.chartStyle) {
          case SubIndicatorChartType.candle:
            // TODO: Handle this case.
            break;
          case SubIndicatorChartType.stick:
            paintBar(
                context,
                offset,
                i,
                targetIndicator.values[i + index].reversed.first!.value ?? 0.0,
                range,
                targetIndicator.values[i + index].reversed.first!.color);
            break;
          case SubIndicatorChartType.line:
            // TODO: Handle this case.
            break;
          case SubIndicatorChartType.candle0:
            // TODO: Handle this case.
            break;
          case SubIndicatorChartType.stick0:
            // TODO: Handle this case.
            break;
          case SubIndicatorChartType.line0:
            if (path == null) {
              path = Path()
                ..moveTo(
                    size.width + offset.dx - (i + 0.5) * barWidth,
                    offset.dy +
                        (size.height * (1 - ((value - low) / (high - low)))));
            } else {
              path.lineTo(
                  size.width + offset.dx - (i + 0.5) * barWidth,
                  offset.dy +
                      (size.height * (1 - ((value - low) / (high - low)))));
            }
            break;
          case SubIndicatorChartType.fill:
            // TODO: Handle this case.
            break;
          case SubIndicatorChartType.dashLine:
            // TODO: Handle this case.
            break;
        }
      }
      if (path != null)
        context.canvas.drawPath(
            path,
            Paint()
              ..color = targetIndicator.values[0].reversed.toList()[li]!.color
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke);
    }

    context.canvas.save();
    context.canvas.restore();
  }
}
