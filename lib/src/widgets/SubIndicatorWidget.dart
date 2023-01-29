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

    for (var draw in drawing) {
      var targetCandles = draw.x
          .map((e) => candles.indexWhere((element) => element.isContain(e)))
          .toList();

      if (draw.type == DrawingType.line) {
        var yVal = offset.dy + (high - draw.y.first) / range;
        context.canvas.drawLine(
            Offset(offset.dx, yVal),
            Offset(offset.dx + size.width, yVal),
            Paint()
              ..color = draw.fillColor.firstOrNull ?? Colors.black
              ..strokeWidth = draw.width ?? 1.0
              ..style = PaintingStyle.stroke);
      }
      if (draw.type == DrawingType.xline) {




        var startY = offset.dy + (high - draw.y.first);
        var endY = offset.dy + (high - draw.y.last);
        var diff = targetCandles.first - targetCandles.last ;
        if (diff == 0) {
          continue;
        }
        var a = (endY - startY) / (diff * barWidth*2);
        var b = startY - a * (targetCandles.first);
        var xlast = size.width +
            offset.dx -
            (targetCandles.last - index + 1 + 0.5) * barWidth;
        var xfirst = size.width +
            offset.dx -
            (targetCandles.first - index + 1 + 0.5) * barWidth;

        var ylast = offset.dy + (high - draw.y.last) / range;
        var yfirst = offset.dy + (high - draw.y.first) / range;

        var dx = xlast - xfirst;
        var dy = ylast - yfirst;

        var alpha = dy / dx;
        var beta = yfirst - alpha * xfirst;

        context.canvas.drawLine(
            Offset(
              offset.dx,
              (alpha * offset.dx + beta),
            ),
            Offset(
              offset.dx + size.width,
              (alpha * (offset.dx + size.width) + beta),
            ),
            Paint()
              ..color = draw.fillColor.firstOrNull ?? Colors.black
              ..strokeWidth = draw.width ?? 1.0
              ..style = PaintingStyle.stroke);
        // context.canvas.drawLine(
        //     Offset(
        //       xfirst,
        //       yfirst,
        //     ),
        //     Offset(
        //       xlast,
        //       ylast,
        //     ),
        //     Paint()
        //       ..color = draw.fillColor.firstOrNull ?? Colors.black
        //       ..strokeWidth = draw.value ?? 1.0
        //       ..style = PaintingStyle.stroke);
        // context.canvas.drawLine(
        //     Offset(
        //         size.width +
        //             offset.dx -
        //             (targetCandles.first - index + 0.5) * barWidth,
        //         startY / range),
        //     Offset(size.width + offset.dx - (0.5) * barWidth,
        //         (b + a * index) / range),
        //     Paint()
        //       ..color = Colors.black
        //       ..strokeWidth = draw.value ?? 1.0
        //       ..style = PaintingStyle.stroke);
        // context.canvas.drawLine(
        //     Offset(
        //         size.width +
        //             offset.dx -
        //             (targetCandles.first - index + 0.5) * barWidth,
        //         startY / range),
        //     Offset(
        //         offset.dx - (targetCandles.first - index + 0.5) * barWidth,
        //         a * size.width + b),
        //     Paint()
        //       ..color = Colors.black
        //       ..strokeWidth = draw.value ?? 1.0
        //       ..style = PaintingStyle.stroke);
      }

      if (draw.type == DrawingType.divideLine) {
        const int dashWidth = 10;
        const int dashSpace = 2;

        double startX = 0;
        var yVal = offset.dy + (high - draw.y.first) / range;
        Paint()
          ..color = draw.fillColor.firstOrNull ?? Colors.black
          ..strokeWidth = draw.width ?? 1.0
          ..style = PaintingStyle.stroke;

        var textPainter = TextPainter(
            text: TextSpan(
              text: draw.name,
              style: TextStyle(
                color: draw.textColor ?? Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: "Noto Sans",
                letterSpacing: 0,
              ),
            ))
          ..textDirection = TextDirection.ltr
          ..textAlign = TextAlign.center
          ..layout();
        if (index < 1) {
          while (startX <
              (size.width -
                  (-2.5 - index) * barWidth -
                  textPainter.width / 3)) {
            // Draw a small line.
            context.canvas.drawLine(
                Offset(startX, yVal),
                Offset(startX + dashWidth, yVal),
                Paint()
                  ..color = draw.textColor ?? Colors.black
                  ..strokeWidth = draw.width ?? 3.0
                  ..style = PaintingStyle.stroke);
            // Update the starting X
            startX += dashWidth + dashSpace;
          }
        } else {
          while (startX < size.width) {
            // Draw a small line.
            context.canvas.drawLine(
                Offset(startX, yVal),
                Offset(startX + dashWidth, yVal),
                Paint()
                  ..color = draw.borderColor.firstOrNull ?? Colors.black
                  ..strokeWidth = draw.width ?? 3.0
                  ..style = PaintingStyle.stroke);

            // Update the starting X
            startX += dashWidth + dashSpace;
          }
        }

        if (index < 1) {
          var background = Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.black
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true;

          context.canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(
                      center: Offset(
                          (size.width -
                              (-2.5 - index) * barWidth +
                              textPainter.width / 2),
                          yVal),
                      width: textPainter.width + 30,
                      height: textPainter.height + 10)
                  // Rect.fromLTWH(
                  //     (size.width -
                  //         (10 - index) * barWidth +
                  //         textPainter.width * 2),
                  //     yVal - textPainter.height / 2 - 5,
                  //     textPainter.width + 30,
                  //     textPainter.height + 10)
                  ,
                  Radius.circular(15.0)),
              Paint()
                ..style = PaintingStyle.fill
                ..color = Colors.white
                ..strokeWidth = 1.0);
          context.canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(
                      center: Offset(
                          (size.width -
                              (-2.5 - index) * barWidth +
                              textPainter.width / 2),
                          yVal),
                      width: textPainter.width + 30,
                      height: textPainter.height + 10)
                  // Rect.fromLTWH(
                  //     (size.width -
                  //         (10 - index) * barWidth +
                  //         textPainter.width * 2),
                  //     yVal - textPainter.height / 2 - 5,
                  //     textPainter.width + 30,
                  //     textPainter.height + 10)
                  ,
                  Radius.circular(15.0)),
              Paint()
                ..style = PaintingStyle.fill
                ..color =
                    draw.textColor ?? draw.fillColor.firstOrNull ?? Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = draw.width ?? 1.0);
          // context.canvas.drawRRect(
          //     RRect.fromRectAndRadius(
          //         Rect.fromLTWH(
          //             (size.width -
          //                 (10 - index) * barWidth +
          //                 textPainter.width * 2),
          //             yVal - textPainter.height / 2 - 5,
          //             textPainter.width + 30,
          //             textPainter.height + 10),
          //         Radius.circular(15.0)),
          //     background);

          textPainter.paint(
            context.canvas,
            Offset((size.width - (-2.5 - index) * barWidth),
                yVal - textPainter.height / 2),
          );
        }
      }

      if (draw.type == DrawingType.circle) {
        var startX = size.width +
            offset.dx -
            (targetCandles.first - index + 0.5) * barWidth;
        var endY = offset.dy + (high - draw.y.first) / range;

        context.canvas.drawCircle(
            Offset(startX, endY),
            draw.width!,
            Paint()
              ..color = draw.borderColor.firstOrNull ?? Colors.transparent
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke);

        context.canvas.drawCircle(
            Offset(startX, endY),
            draw.width!,
            Paint()
              ..color = draw.fillColor.firstOrNull ?? Colors.transparent
              ..strokeWidth = 0.0
              ..style = PaintingStyle.fill);
      }

      if (draw.type == DrawingType.fibonacciRetracement) {
        var startY = offset.dy + (high - draw.y.first) / range;
        var endY = offset.dy + (high - draw.y.last) / range;
        var xlast = size.width +
            offset.dx -
            (targetCandles.last - index + 1 + 0.5) * barWidth;
        var xfirst = size.width +
            offset.dx -
            (targetCandles.first - index + 1 + 0.5) * barWidth;

        var diffY = endY - startY;

        //baseline
        context.canvas.drawLine(
            Offset(xfirst, startY),
            Offset(xlast, startY),
            Paint()
              ..color = draw.borderColor.firstOrNull ?? Colors.transparent
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke);
        // fill 0 - 0.236
        context.canvas.drawRect(
            Rect.fromPoints(
                Offset(xfirst, startY), Offset(xlast, startY + diffY * 0.236)),
            Paint()..color = Colors.red.withOpacity(0.3));
        //line1
        context.canvas.drawLine(
            Offset(xfirst, startY + diffY * 0.236),
            Offset(xlast, startY + diffY * 0.236),
            Paint()..color = Colors.black);

        // fill 0.236 - 0.382

        context.canvas.drawRect(
            Rect.fromPoints(Offset(xfirst, startY + diffY * 0.236),
                Offset(xlast, startY + diffY * 0.382)),
            Paint()..color = Colors.orange.withOpacity(0.3));

        //line2
        context.canvas.drawLine(
            Offset(xfirst, startY + diffY * 0.382),
            Offset(xlast, startY + diffY * 0.382),
            Paint()..color = Colors.black);

        // fill 0.382 - 0.5

        context.canvas.drawRect(
            Rect.fromPoints(Offset(xfirst, startY + diffY * 0.382),
                Offset(xlast, startY + diffY * 0.5)),
            Paint()..color = Colors.yellow.withOpacity(0.3));

        //line2
        context.canvas.drawLine(Offset(xfirst, startY + diffY * 0.5),
            Offset(xlast, startY + diffY * 0.5), Paint()..color = Colors.black);

        // fill 0.5 - 0.786

        context.canvas.drawRect(
            Rect.fromPoints(Offset(xfirst, startY + diffY * 0.5),
                Offset(xlast, startY + diffY * 0.786)),
            Paint()..color = Colors.green.withOpacity(0.3));

        //line2
        context.canvas.drawLine(
            Offset(xfirst, startY + diffY * 0.786),
            Offset(xlast, startY + diffY * 0.786),
            Paint()..color = Colors.black);

        // fill 0.786 - 1

        context.canvas.drawRect(
            Rect.fromPoints(Offset(xfirst, startY + diffY * 0.786),
                Offset(xlast, startY + diffY * 1)),
            Paint()..color = Colors.blue.withOpacity(0.3));

        //line2
        context.canvas.drawLine(Offset(xfirst, startY + diffY),
            Offset(xlast, startY + diffY), Paint()..color = Colors.black);
      }
    }

    context.canvas.save();
    context.canvas.restore();
  }
}
