import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/candle.dart';
import 'package:candlesticks/src/models/drawing.dart';
import 'package:candlesticks/src/models/main_window_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainWindowIndicatorWidget extends LeafRenderObjectWidget {
  final List<IndicatorComponentData> indicatorDatas;
  final int index;
  final double candleWidth;
  final double high;
  final double low;
  final List<ChartDrawing> drawing;
  Duration gap;

  final List<Candle> candles;

  List<IndicatorFillData> indicatorFills;

  MainWindowIndicatorWidget(
      {required this.indicatorDatas,
      required this.index,
      required this.candleWidth,
      required this.low,
      required this.high,
      this.drawing = const [],
      required List<Candle> this.candles,
      this.gap = const Duration(hours: 1),
      List<IndicatorFillData> this.indicatorFills = const []});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MainWindowIndicatorRenderObject(indicatorDatas, index, candleWidth,
        low, high, drawing, candles, gap, indicatorFills);
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

  List<IndicatorFillData> indicatorFills;

  MainWindowIndicatorRenderObject(
      List<IndicatorComponentData> indicatorDatas,
      int index,
      double candleWidth,
      double low,
      double high,
      this.drawing,
      this.candles,
      this.gap,
      List<IndicatorFillData> this.indicatorFills) {
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

    _indicatorDatas.where((element) => element.visible).forEach((element) {
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
    indicatorFills.where((element) => element.visible).forEach((element) {
      Offset? offset1;
      Offset? offset2;
      for (int i = 0; (i + 1) * _candleWidth < size.width; i++) {
        if (element.indicatorData
                .every((element) => element.values.length <= i + _index) ||
            i + _index < 0 ||
            element.indicatorData.every((e1) => e1.values[i + _index] == null))
          continue;

        if (offset1 == null && offset2 == null) {
          offset1 = Offset(
              size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy +
                  (_high - element.indicatorData[0].values[i + _index]!) /
                      range);
          offset2 = Offset(
              size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy +
                  (_high - element.indicatorData[1].values[i + _index]!) /
                      range);
        } else {
          var newOffset1 = Offset(
              size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy +
                  (_high - element.indicatorData[0].values[i + _index]!) /
                      range);

          var newOffset2 = Offset(
              size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy +
                  (_high - element.indicatorData[1].values[i + _index]!) /
                      range);
          if ((offset1!.dy < offset2!.dy && newOffset1.dy < newOffset2.dy) ||
              (offset1!.dy >= offset2!.dy && newOffset1.dy >= newOffset2.dy)) {
            var path = Path();
            path.moveTo(offset1!.dx, offset1!.dy);
            path.lineTo(offset2!.dx, offset2!.dy);

            path.lineTo(newOffset2.dx, newOffset2.dy);
            path.lineTo(newOffset1.dx, newOffset1.dy);

            var paint = Paint()
              ..style = PaintingStyle.fill
              ..color =
                  (offset1!.dy >= offset2!.dy && newOffset1.dy >= newOffset2.dy)
                      ? element.bullColor
                      : element.bearColor;

            context.canvas.drawPath(path, paint);
          } else {
            var path = Path();

            var center = Offset((offset1.dx + newOffset1.dx) / 2,
                (offset1.dy + newOffset1.dy) / 2);
            path.moveTo(offset1!.dx, offset1!.dy);
            path.lineTo(offset2!.dx, offset2!.dy);

            path.lineTo(center.dx, center.dy);

            var paint = Paint()
              ..style = PaintingStyle.fill
              ..color = !(offset1!.dy >= offset2!.dy &&
                      newOffset1.dy >= newOffset2.dy)
                  ? element.bullColor
                  : element.bearColor;

            context.canvas.drawPath(path, paint);
            var path2 = Path();
            path2.moveTo(center.dx, center.dy);

            path2.lineTo(newOffset2.dx, newOffset2.dy);
            path2.lineTo(newOffset1.dx, newOffset1.dy);

            var paint2 = Paint()
              ..style = PaintingStyle.fill
              ..color =
                  (offset1!.dy >= offset2!.dy && newOffset1.dy >= newOffset2.dy)
                      ? element.bullColor
                      : element.bearColor;
            context.canvas.drawPath(path2, paint2);
          }
          offset1 = Offset(
              size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy +
                  (_high - element.indicatorData[0].values[i + _index]!) /
                      range);
          offset2 = Offset(
              size.width + offset.dx - (i + 0.5) * _candleWidth,
              offset.dy +
                  (_high - element.indicatorData[1].values[i + _index]!) /
                      range);
        }
      }

      // if (path != null)
      //   context.canvas.drawPath(
      //       path,
      //       Paint()
      //         ..color = element.color
      //         ..strokeWidth = 1
      //         ..style = PaintingStyle.stroke);
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
        if (diff == 0) {
          continue;
        }
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

      if (draw.type == DrawingType.divideLine) {
        const int dashWidth = 10;
        const int dashSpace = 2;

        double startX = 0;
        var yVal = offset.dy + (_high - draw.y.first) / range;
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
        if (_index < 1) {
          while (startX <
              (size.width -
                  (-2.5 - _index) * _candleWidth -
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

        if (_index < 1) {
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
                              (-2.5 - _index) * _candleWidth +
                              textPainter.width / 2),
                          yVal),
                      width: textPainter.width + 30,
                      height: textPainter.height + 10)
                  // Rect.fromLTWH(
                  //     (size.width -
                  //         (10 - _index) * _candleWidth +
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
                              (-2.5 - _index) * _candleWidth +
                              textPainter.width / 2),
                          yVal),
                      width: textPainter.width + 30,
                      height: textPainter.height + 10)
                  // Rect.fromLTWH(
                  //     (size.width -
                  //         (10 - _index) * _candleWidth +
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
          //                 (10 - _index) * _candleWidth +
          //                 textPainter.width * 2),
          //             yVal - textPainter.height / 2 - 5,
          //             textPainter.width + 30,
          //             textPainter.height + 10),
          //         Radius.circular(15.0)),
          //     background);

          textPainter.paint(
            context.canvas,
            Offset((size.width - (-2.5 - _index) * _candleWidth),
                yVal - textPainter.height / 2),
          );
        }
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

        context.canvas.drawCircle(
            Offset(startX, endY),
            draw.width!,
            Paint()
              ..color = draw.fillColor.firstOrNull ?? Colors.transparent
              ..strokeWidth = 0.0
              ..style = PaintingStyle.fill);
      }

      if (draw.type == DrawingType.fibonacciRetracement) {
        var startY = offset.dy + (_high - draw.y.first) / range;
        var endY = offset.dy + (_high - draw.y.last) / range;
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
