import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/candle.dart';
import 'package:candlesticks/src/models/drawing.dart';
import 'package:candlesticks/src/models/main_window_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/main_window_indicator.dart';

class MainWindowIndicatorWidget extends LeafRenderObjectWidget {
  final List<IndicatorComponentData> indicatorDatas;
  final int index;
  final double candleWidth;
  final double high;
  final double low;
  final List<ChartDrawing> drawing;
  Duration gap;

  final List<Candle> candles;

  MainWindowIndicatorWidget(
      {required this.indicatorDatas,
      required this.index,
      required this.candleWidth,
      required this.low,
      required this.high,
      this.drawing = const [],
      required List<Candle> this.candles,
      this.gap = const Duration(hours: 1)});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MainWindowIndicatorRenderObject(
        indicatorDatas, index, candleWidth, low, high, drawing, candles, gap);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    MainWindowIndicatorRenderObject candlestickRenderObject =
        renderObject as MainWindowIndicatorRenderObject;

    if (kReleaseMode) {
      candlestickRenderObject.markNeedsPaint();
    }
    candlestickRenderObject._indicatorDatas = indicatorDatas;
    candlestickRenderObject._index = index;
    candlestickRenderObject._candleWidth = candleWidth;
    candlestickRenderObject._high = high;
    candlestickRenderObject._low = low;
    candlestickRenderObject.drawing = drawing;
    candlestickRenderObject.gap = gap;
    candlestickRenderObject.markNeedsPaint();
    super.updateRenderObject(context, renderObject);
  }
}

class MainWindowIndicatorRenderObject extends RenderBox {
  late List<IndicatorComponentData> _indicatorDatas;
  late int _index;
  late double _candleWidth;
  late double _low;
  late double _high;
  late List<ChartDrawing> drawing;
  final List<Candle> candles;
  Duration gap;

  MainWindowIndicatorRenderObject(
      List<IndicatorComponentData> indicatorDatas,
      int index,
      double candleWidth,
      double low,
      double high,
      this.drawing,
      this.candles,
      this.gap) {
    _indicatorDatas = indicatorDatas;
    _index = index;
    _candleWidth = candleWidth;
    _low = low;
    _high = high;
  }

  /// set size as large as possible
  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    double range = (_high - _low) / size.height;

    _indicatorDatas.forEach((element) {
      Path? path;
      for (int i = 0; (i + 1) * _candleWidth < size.width; i++) {
        if (i + _index >= element.values.length ||
            i + _index < 0 ||
            element.values[i + _index] == null) continue;

        if (element.parentIndicator.label != null && i + _index == 0) {
          var textPainter = TextPainter(
              text: TextSpan(
            text: element.parentIndicator.label!,
            style: TextStyle(
              color: Color(
                0xffff000d,
              ),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: "Noto Sans",
              letterSpacing: 0,
            ),
          ))
            ..textDirection = TextDirection.ltr
            ..textAlign = TextAlign.center
            ..layout();

          textPainter.paint(
              context.canvas,
              Offset(
                  (size.width + offset.dx - (i + 0.5)) - textPainter.size.width,
                  (offset.dy + (_high - element.values[i + _index]!) / range) -
                      textPainter.size.height / 2));
        }

        if (path == null) {
          path = Path()
            ..moveTo(size.width + offset.dx - (i + 0.5) * _candleWidth,
                offset.dy + (_high - element.values[i + _index]!) / range);
        } else {
          path.lineTo(size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy + (_high - element.values[i + _index]!) / range);
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
    var showCandleLength = (size.width / _candleWidth);

    for (ChartDrawing draw in drawing) {
      var targetCandles = draw.x
          .map((e) => candles.indexWhere((element) => element.isContain(e)))
          .toList()
        ..sort();
      if (draw.type == DrawingType.line) {
        var yVal = offset.dy + (_high - draw.y.first) / range;
        context.canvas.drawLine(
            Offset(offset.dx, yVal),
            Offset(offset.dx + size.width, yVal),
            Paint()
              ..color = draw.fillColor.firstOrNull ?? Colors.black
              ..strokeWidth = draw.width ?? 1.0
              ..style = PaintingStyle.stroke);
      }
      if (draw.type == DrawingType.xline) {
        var startY = offset.dy + (_high - draw.y.first);
        var endY = offset.dy + (_high - draw.y.last);
        var x1 = draw.x.first;
        var x2 = draw.x.last;
        var diff = targetCandles.last - targetCandles.first;

        var a = (endY - startY) / (diff * _candleWidth);
        var b = startY - a * (targetCandles.first);
        var xlast = size.width +
            offset.dx -
            (targetCandles.last - _index + 1 + 0.5) * _candleWidth;
        var xfirst = size.width +
            offset.dx -
            (targetCandles.first - _index + 1 + 0.5) * _candleWidth;

        var ylast = offset.dy + (_high - draw.y.last) / range;
        var yfirst = offset.dy + (_high - draw.y.first) / range;

        var dx = xlast - xfirst;
        var dy = ylast - yfirst;

        var alpha = dy / dx;
        var beta = yfirst - alpha * xfirst;

        context.canvas.drawLine(
            Offset(
              offset.dx,
              alpha * offset.dx + beta,
            ),
            Offset(
              offset.dx + size.width,
              alpha * (offset.dx + size.width) + beta,
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
        //             (targetCandles.first - _index + 0.5) * _candleWidth,
        //         startY / range),
        //     Offset(size.width + offset.dx - (0.5) * _candleWidth,
        //         (b + a * _index) / range),
        //     Paint()
        //       ..color = Colors.black
        //       ..strokeWidth = draw.value ?? 1.0
        //       ..style = PaintingStyle.stroke);
        // context.canvas.drawLine(
        //     Offset(
        //         size.width +
        //             offset.dx -
        //             (targetCandles.first - _index + 0.5) * _candleWidth,
        //         startY / range),
        //     Offset(
        //         offset.dx - (targetCandles.first - _index + 0.5) * _candleWidth,
        //         a * size.width + b),
        //     Paint()
        //       ..color = Colors.black
        //       ..strokeWidth = draw.value ?? 1.0
        //       ..style = PaintingStyle.stroke);
      }
      if (draw.type == DrawingType.circle) {
        var startX = size.width +
            offset.dx -
            (targetCandles.first - _index + 0.5) * _candleWidth;
        var endY = offset.dy + (_high - draw.y.first) / range;

        context.canvas.drawCircle(
            Offset(startX, endY),
            draw.width!,
            Paint()
              ..color = draw.borderColor.firstOrNull ?? Colors.transparent
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke);
      }

      if (draw.type == DrawingType.fibonacciRetracement) {
        var startY = offset.dy + (_high - draw.y.first);
        var endY = offset.dy + (_high - draw.y.last);
        var x1 = draw.x.first;
        var x2 = draw.x.last;
        var xlast = size.width +
            offset.dx -
            (targetCandles.last - _index + 1 + 0.5) * _candleWidth;
        var xfirst = size.width +
            offset.dx -
            (targetCandles.first - _index + 1 + 0.5) * _candleWidth;

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
            Paint()..color = Colors.red.withOpacity(0.3));

        //line2
        context.canvas.drawLine(
            Offset(xfirst, startY + diffY * 0.382),
            Offset(xlast, startY + diffY * 0.382),
            Paint()..color = Colors.black);
      }
    }

    context.canvas.save();
    context.canvas.restore();
  }
}
