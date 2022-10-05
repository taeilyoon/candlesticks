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
    var showCandleLength = (size.width / _candleWidth).floor();

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

      if (draw.type == DrawingType.divideLine) {
        const int dashWidth = 4;
        const int dashSpace = 4;

        // Start to draw from left size.
        // Of course, you can change it to match your requirement.
        double startX = 0;

        // Repeat drawing until we reach the right edge.
        // In our example, size.with = 300 (from the SizedBox)
        var yVal = offset.dy + (_high - draw.y.first) / range;

        while (startX < size.width) {
          // Draw a small line.
          context.canvas.drawLine(
              Offset(startX, yVal),
              Offset(startX + dashWidth, yVal),
              Paint()
                ..color = draw.fillColor.firstOrNull ?? Colors.black
                ..strokeWidth = draw.width ?? 3.0
                ..style = PaintingStyle.stroke);
          // Update the starting X
          startX += dashWidth + dashSpace;
        }
      }

      if (draw.type == DrawingType.xline) {
        var startY = offset.dy + (_high - draw.y.first);
        var endY = offset.dy + (_high - draw.y.last);
        var x1 = draw.x.first;
        var x2 = draw.x.last;
        var diff = targetCandles.last - targetCandles.first;

        var a = ((size.width +
                offset.dx -
                (targetCandles.first - _index + 0.5) * _candleWidth -
                size.width +
                offset.dx -
                (targetCandles.last - _index + 0.5) * _candleWidth)) /
            diff;
        var b = startY - a * targetCandles.first;
        context.canvas.drawLine(
            Offset(
                offset.dx - (targetCandles.first - _index + 0.5) * _candleWidth,
                a + b),
            Offset(
                size.width +
                    offset.dx -
                    (targetCandles.last - _index + 0.5) * _candleWidth,
                endY / range),
            Paint()
              ..color = Colors.black
              ..strokeWidth = draw.width ?? 1.0
              ..style = PaintingStyle.stroke);
        context.canvas.drawLine(
            Offset(
                size.width +
                    offset.dx -
                    (targetCandles.first - _index + 0.5) * _candleWidth,
                startY / range),
            Offset(
                size.width +
                    offset.dx -
                    (targetCandles.last - _index + 0.5) * _candleWidth,
                endY / range),
            Paint()
              ..color = draw.fillColor.firstOrNull ?? Colors.black
              ..strokeWidth = draw.width ?? 1.0
              ..style = PaintingStyle.stroke);

        context.canvas.drawLine(
            Offset(
                size.width +
                    offset.dx -
                    (targetCandles.first - _index + 0.5) * _candleWidth,
                startY / range),
            Offset(
                offset.dx - (targetCandles.first - _index + 0.5) * _candleWidth,
                a * size.width + b),
            Paint()
              ..color = Colors.black
              ..strokeWidth = draw.width ?? 1.0
              ..style = PaintingStyle.stroke);
      }
    }
    // for (int i = 0; (i + 1) * _candleWidth < size.width; i++) {
    //   if (i + _index > 0) {
    //     for (ChartDrawing draw in drawing) {
    //       var w = draw.x.firstWhereOrNull((element) =>
    //           !element.isBefore(candles[i + _index].date) &&
    //           (candles.getOrNull(i - 1 + _index)?.date?.isAfter(element) ??
    //               true));
    //
    //       if (w != null) {
    //         var startX = size.width + offset.dx - (i + 0.5) * _candleWidth;
    //         var endY = offset.dy + (_high - draw.y.first) / range;
    //
    //         switch (draw.type) {
    //           case DrawingType.circle:
    //             context.canvas.drawCircle(
    //                 Offset(startX, endY),
    //                 draw.value!,
    //                 Paint()
    //                   ..color =
    //                       draw.borderColor.firstOrNull ?? Colors.transparent
    //                   ..strokeWidth = 1.0
    //                   ..style = PaintingStyle.stroke);
    //             context.canvas.drawCircle(
    //                 Offset(startX, endY),
    //                 draw.value!,
    //                 Paint()
    //                   ..color = draw.fillColor.firstOrNull ?? Colors.black);
    //
    //             break;
    //           case DrawingType.simpleSquare:
    //             context.canvas.drawRect(
    //                 Offset(startX, endY) & const Size(200, 150), Paint());
    //             break;
    //         }
    //       }
    //     }
    //   }
    // }

    context.canvas.save();
    context.canvas.restore();
  }
}
