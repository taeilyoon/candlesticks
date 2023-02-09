import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/candle.dart';
import 'package:candlesticks/src/models/drawing.dart';
import 'package:candlesticks/src/models/main_window_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MainWindowIndicatorWidget extends LeafRenderObjectWidget {
  final List<IndicatorComponentData> indicatorDatas;
  final int index;
  final double candleWidth;
  final double high;
  final double low;
  final List<ChartDrawing> drawing;

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
      List<IndicatorFillData> this.indicatorFills = const []});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MainWindowIndicatorRenderObject(indicatorDatas, index, candleWidth,
        low, high, drawing, candles, indicatorFills);
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
    candlestickRenderObject.indicatorFills = indicatorFills;
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

  late List<IndicatorFillData> indicatorFills;

  MainWindowIndicatorRenderObject(
      List<IndicatorComponentData> indicatorDatas,
      int index,
      double candleWidth,
      double low,
      double high,
      this.drawing,
      this.candles,
      List<IndicatorFillData> indicatorFill) {
    _indicatorDatas = indicatorDatas;
    _index = index;
    _candleWidth = candleWidth;
    _low = low;
    _high = high;
    indicatorFills = indicatorFill;
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
              (offset1.dy >= offset2.dy && newOffset1.dy >= newOffset2.dy)) {
            var path = Path();
            path.moveTo(offset1.dx, offset1.dy);
            path.lineTo(offset2.dx, offset2.dy);

            path.lineTo(newOffset2.dx, newOffset2.dy);
            path.lineTo(newOffset1.dx, newOffset1.dy);

            var paint = Paint()
              ..style = PaintingStyle.fill
              ..color =
                  (offset1.dy >= offset2.dy && newOffset1.dy >= newOffset2.dy)
                      ? element.bullColor
                      : element.bearColor;

            context.canvas.drawPath(path, paint);
          } else {
            var path = Path();

            var center = Offset((offset1.dx + newOffset1.dx) / 2,
                (offset1.dy + newOffset1.dy) / 2);
            path.moveTo(offset1.dx, offset1.dy);
            path.lineTo(offset2.dx, offset2.dy);

            path.lineTo(center.dx, center.dy);

            var paint = Paint()
              ..style = PaintingStyle.fill
              ..color =
                  !(offset1.dy >= offset2.dy && newOffset1.dy >= newOffset2.dy)
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
                  (offset1.dy >= offset2.dy && newOffset1.dy >= newOffset2.dy)
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
    });

    var showCandleLength = (size.width / _candleWidth);

    for (ChartDrawing draw in drawing) {
      var targetCandles = draw.x
          .map((e) => candles.indexWhere((element) => element.isContain(e)))
          .toList();

      if (draw is LineDrawing) {
        var startY = offset.dy + (_high - draw.y.first);
        var endY = offset.dy + (_high - draw.y.last);
        var diff = targetCandles.first - targetCandles.last;
        if (diff == 0) {
          continue;
        }
        var a = (endY - startY) / (diff * _candleWidth * 2);
        var b = startY - a * (targetCandles.first);
        var xlast = size.width +
            offset.dx -
            (targetCandles.last - _index + 1 + 0.5) * _candleWidth;
        var xfirst = size.width +
            offset.dx -
            (targetCandles.first - _index + 0.5) * _candleWidth;

        var ylast = offset.dy + (_high - draw.y.last) / range;
        var yfirst = offset.dy + (_high - draw.y.first) / range;

        var dx = xlast - xfirst;
        var dy = ylast - yfirst;

        var alpha = dy / dx;
        var beta = yfirst - alpha * xfirst;

        var line = draw as LineDrawing;
        late Offset open;
        late Offset close;
        switch (line.range) {
          case LineRange.open:
            open = Offset(
              offset.dx,
              (alpha * offset.dx + beta),
            );

            close = Offset(
              offset.dx + size.width,
              (alpha * (offset.dx + size.width) + beta),
            );
            break;
          case LineRange.close:
            open = Offset(
              xfirst,
              yfirst,
            );
            close = Offset(
              xlast,
              ylast,
            );
            // TODO: Handle this case.
            break;
          case LineRange.startOpen:
            open = Offset(
              offset.dx,
              (alpha * offset.dx + beta),
            );
            close = Offset(
              xlast,
              ylast,
            );
            // TODO: Handle this case.
            break;
          case LineRange.endOpen:
            open = Offset(
              xfirst,
              yfirst,
            );
            close = Offset(
              offset.dx + size.width,
              (alpha * (offset.dx + size.width) + beta),
            );
            break;
        }
        switch (line.style) {
          case LineStyle.solid:
            context.canvas.drawLine(
                open,
                close,
                Paint()
                  ..color = draw.borderColor.firstOrNull ?? Colors.black
                  ..strokeWidth = draw.width ?? 3.0
                  ..style = PaintingStyle.stroke);
            break;
          case LineStyle.dotted:
            context.canvas.drawDashLine(
                open,
                close,
                Paint()
                  ..color = draw.borderColor.firstOrNull ?? Colors.black
                  ..strokeWidth = line.width ?? 3.0
                  ..style = PaintingStyle.stroke,
                width: draw.width,
                space: draw.width);
            break;
          case LineStyle.dashed:
            context.canvas.drawDashLine(
                open,
                close,
                Paint()
                  ..color = draw.borderColor.firstOrNull ?? Colors.black
                  ..strokeWidth = line.width ?? 3.0
                  ..style = PaintingStyle.stroke,
                width: 30,
                space: 0);
            break;
        }
        continue;
      }

      if (draw is MarkerDrawing) {
        var x = size.width +
            offset.dx -
            (targetCandles.first - _index + 0.5) * _candleWidth;
        var y = offset.dy + (_high - draw.y.first) / range;
        var paint = Paint()
          ..color = draw.borderColor.firstOrNull ?? Colors.black
          ..strokeWidth = draw.width ?? 3.0
          ..style = PaintingStyle.stroke;
        switch (draw.shape) {
          case MarkerType.circle:
            context.canvas.drawCircle(Offset(x, y), draw.size / 2, paint);
            break;
          case MarkerType.square:
            context.canvas.drawRect(
                Rect.fromCenter(
                    center: Offset(x, y), width: draw.size, height: draw.size),
                paint);
            break;
          case MarkerType.diamond:
            context.canvas.drawPath(
                Path()
                  ..addPolygon([
                    Offset(x, y - draw.size),
                    Offset(x + draw.size, y),
                    Offset(x, y + draw.size),
                    Offset(x - draw.size, y)
                  ], true),
                paint);
            break;
        }
        continue;
      }

      if (draw is TextDrawing) {
        var x = size.width +
            offset.dx -
            (targetCandles.first - _index + 0.5) * _candleWidth;
        var y = offset.dy + (_high - draw.y.first) / range;
        var textPainter = TextPainter(
            text: TextSpan(
          text: draw.name,
          style: TextStyle(
            color: draw.textColor,
            fontSize: draw.size,
            fontWeight: FontWeight.w400,
            fontFamily: "Noto Sans",
            letterSpacing: 0,
          ),
        ))
          ..textDirection = TextDirection.ltr
          ..textAlign = TextAlign.center
          ..layout();

        var xPadding = draw.textType == TextDrawingType.normal ? 0.0 : 30;
        var yPadding = draw.textType == TextDrawingType.normal ? 0.0 : 10;
        var dirrectionBubble =
            draw.textType == TextDrawingType.bubbleArrow ? 20 : 0;

        late Offset toffset;
        switch (draw.anchor) {
          case Anchor.top:
            toffset = Offset(x - textPainter.width / 2,
                y - yPadding - dirrectionBubble - textPainter.height);
            break;
          case Anchor.bottom:
            toffset = Offset(
                x - textPainter.width / 2, y + yPadding - dirrectionBubble);
            break;
          case Anchor.center:
            toffset =
                Offset(x - textPainter.width / 2, y - textPainter.height / 2);

            break;
          case Anchor.left:
            toffset = Offset(
                x - xPadding - dirrectionBubble - textPainter.width,
                y - textPainter.height / 2);

            break;
          case Anchor.right:
            toffset = Offset(
                x + xPadding + dirrectionBubble, y - textPainter.height / 2);
            break;
        }
        if (draw.textType == TextDrawingType.bubble ||
            draw.textType == TextDrawingType.bubbleArrow) {
          context.canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(
                    center: Offset(
                      toffset.dx + xPadding / 2,
                      toffset.dy + yPadding,
                    ),
                    width: textPainter.width + xPadding,
                    height: textPainter.height + yPadding,
                  ),
                  Radius.circular(15.0)),
              Paint()
                ..style = PaintingStyle.fill
                ..color = Colors.red
                ..strokeWidth = 1.0);

          context.canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(
                    center: Offset(
                      toffset.dx + xPadding / 2,
                      toffset.dy + yPadding,
                    ),
                    width: textPainter.width + xPadding,
                    height: textPainter.height + yPadding,
                  ),
                  Radius.circular(15.0)),
              Paint()
                ..style = PaintingStyle.fill
                ..color =
                    draw.textColor ?? draw.fillColor.firstOrNull ?? Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0);
        }

        if (draw.textType == TextDrawingType.bubbleArrow) {
          var path = Path();
          path.moveTo(
            toffset.dx+ xPadding / 2 -4 ,
            toffset.dy ,
          );
          path.lineTo(
            toffset.dx+ xPadding / 2 + 4  ,
            toffset.dy ,
          );
          path.lineTo(x, y);
          path.close();
          context.canvas.drawPath(path, Paint()..color = Colors.red);
        }
        textPainter.paint(context.canvas, toffset);
      }

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
        var diff = targetCandles.first - targetCandles.last;
        if (diff == 0) {
          continue;
        }
        var a = (endY - startY) / (diff * _candleWidth * 2);
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
                  yVal - textPainter.height / 2));
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

extension CustomLine on Canvas {
  drawDashLine(
    Offset offset1,
    Offset offset2,
    Paint paint, {
    double? width,
    double? space,
  }) {
    var distance = offset1.distanceTo(offset2);
    var dashWidth = width ?? 20.0;
    var dashSpace = space ?? 20.0;
    var dashCount = (distance / (dashWidth + dashSpace)).floor();
    for (var i = 0; i < dashCount; i++) {
      var startX = offset1.dx + ((offset2.dx - offset1.dx) / dashCount) * i;
      var startY = offset1.dy + ((offset2.dy - offset1.dy) / dashCount) * i;
      var endX = startX + (offset2.dx - offset1.dx) * (dashWidth / distance);
      var endY = startY + (offset2.dy - offset1.dy) * (dashWidth / distance);

      drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }
}

extension OffsetDis on Offset {
  distanceTo(Offset other) {
    var dx = other.dx - this.dx;
    var dy = other.dy - this.dy;
    return math.sqrt(dx * dx + dy * dy);
  }
}
