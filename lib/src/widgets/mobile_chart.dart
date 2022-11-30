import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/constant/view_constants.dart';
import 'package:candlesticks/src/models/drawing.dart';
import 'package:candlesticks/src/models/main_window_indicator.dart';
import 'package:candlesticks/src/models/sub_indicator.dart';
import 'package:candlesticks/src/models/sub_window_indicator.dart';
import 'package:candlesticks/src/utils/helper_functions.dart';
import 'package:candlesticks/src/widgets/SubIndicatorWidget.dart';
import 'package:candlesticks/src/widgets/candle_stick_widget.dart';
import 'package:candlesticks/src/widgets/mainwindow_indicator_widget.dart';
import 'package:candlesticks/src/widgets/price_column.dart';
import 'package:candlesticks/src/widgets/time_row.dart';
import 'package:candlesticks/src/widgets/top_panel.dart';
import 'package:flutter/material.dart';

import 'dash_line.dart';

/// This widget manages gestures
/// Calculates the highest and lowest price of visible candles.
/// Updates right-hand side numbers.
/// And pass values down to [CandleStickWidget].
class MobileChart extends StatefulWidget {
  /// onScaleUpdate callback
  /// called when user scales chart using buttons or scale gesture
  final Function onScaleUpdate;

  /// onHorizontalDragUpdate
  /// callback calls when user scrolls horizontally along the chart
  final Function onHorizontalDragUpdate;

  /// candleWidth controls the width of the single candles.
  /// range: [2...10]
  final double candleWidth;

  /// list of all candles to display in chart
  final List<Candle> candles;

  /// index of the newest candle to be displayed
  /// changes when user scrolls along the chart
  final int index;

  /// holds main window indicators data and high and low prices.
  final MainWindowDataContainer mainWindowDataContainer;

  /// How chart price range will be adjusted when moving chart
  final ChartAdjust chartAdjust;

  final CandleSticksStyle style;

  final void Function(double) onPanDown;
  final void Function() onPanEnd;

  final void Function(String)? onRemoveIndicator;

  final Function() onReachEnd;

  final OnChartPanStart? onChartPanStart;
  final OnChartPanUpdate? onChartPanUpadte;
  final OnChartPanEnd? onChartPanEnd;
  bool isDrawing;
  List<List<ChartDrawing>> drawing;

  final clip;

  final void Function(int i, List<Indicator> updated) indicatorUpdated;

  List<SubIndicator> subIndicator;

  SubIndicatorDataContainer subWindowDataContainer;

  Function(int i) onSubIndicatorSettingPressed;

  MobileChart(
      {required this.style,
      required this.onScaleUpdate,
      required this.onHorizontalDragUpdate,
      required this.candleWidth,
      required this.candles,
      required this.index,
      required this.chartAdjust,
      required this.onPanDown,
      required this.onPanEnd,
      required this.onReachEnd,
      required this.mainWindowDataContainer,
      required this.onRemoveIndicator,
      required this.indicatorUpdated,
      required this.subIndicator,
      this.clip = Clip.hardEdge,
      this.onChartPanStart,
      this.onChartPanUpadte,
      this.onChartPanEnd,
      this.isDrawing = false,
      this.drawing = const [[], [], []],
      required priceIndicatorOption,
      required this.onSubIndicatorSettingPressed,
      required SubIndicatorDataContainer this.subWindowDataContainer});

  @override
  State<MobileChart> createState() => _MobileChartState();
}

class _MobileChartState extends State<MobileChart> {
  double? longPressX;
  double? longPressY;
  bool showIndicatorNames = false;
  double? manualScaleHigh;
  double? manualScaleLow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // determine charts width and height
        final double maxWidth = constraints.maxWidth - PRICE_BAR_WIDTH;
        final double maxHeight = constraints.maxHeight - DATE_BAR_HEIGHT;

        // visible candles start and end indexes
        final int candlesStartIndex = max(widget.index, 0);
        final int candlesEndIndex = min(
            maxWidth ~/ widget.candleWidth + widget.index,
            widget.candles.length - 1);

        if (candlesEndIndex == widget.candles.length - 1) {
          Future(() {
            widget.onReachEnd();
          });
        }

        List<Candle> inRangeCandles = widget.candles
            .getRange(candlesStartIndex, candlesEndIndex + 1)
            .toList();

        double candlesHighPrice = 0;
        double candlesLowPrice = 0;
        if (manualScaleHigh != null) {
          candlesHighPrice = manualScaleHigh!;
          candlesLowPrice = manualScaleLow!;
        } else if (widget.chartAdjust == ChartAdjust.visibleRange) {
          candlesHighPrice = widget.mainWindowDataContainer.highs
              .getRange(candlesStartIndex, candlesEndIndex + 1)
              .reduce(max);
          candlesLowPrice = widget.mainWindowDataContainer.lows
              .getRange(candlesStartIndex, candlesEndIndex + 1)
              .reduce(min);
        } else if (widget.chartAdjust == ChartAdjust.fullRange) {
          candlesHighPrice = widget.mainWindowDataContainer.highs.reduce(max);
          candlesLowPrice = widget.mainWindowDataContainer.lows.reduce(min);
        }

        if (candlesHighPrice == candlesLowPrice) {
          candlesHighPrice += 10;
          candlesLowPrice -= 10;
        }

        // calculate priceScale
        double chartHeight = maxHeight * 0.75 - 2 * MAIN_CHART_VERTICAL_PADDING;

        // calculate highest volume
        double volumeHigh = inRangeCandles.map((e) => e.volume).reduce(max);

        if (longPressX != null && longPressY != null) {
          longPressX = max(longPressX!, 0);
          longPressX = min(longPressX!, maxWidth);
          longPressY = max(longPressY!, 0);
          longPressY = min(longPressY!, maxHeight);
        }

        return TweenAnimationBuilder(
          tween: Tween(begin: candlesHighPrice, end: candlesHighPrice),
          duration: Duration(milliseconds: manualScaleHigh == null ? 300 : 0),
          builder: (context, double high, _) {
            return TweenAnimationBuilder(
              tween: Tween(begin: candlesLowPrice, end: candlesLowPrice),
              duration:
                  Duration(milliseconds: manualScaleHigh == null ? 300 : 0),
              builder: (context, double low, _) {
                final currentCandle = longPressX == null
                    ? null
                    : widget.candles[min(
                        max(
                            (maxWidth - longPressX!) ~/ widget.candleWidth +
                                widget.index,
                            0),
                        widget.candles.length - 1)];
                return Container(
                  color: widget.style.background,
                  child: Stack(
                    children: [
                      TimeRow(
                        style: widget.style,
                        indicatorX: longPressX,
                        candles: widget.candles,
                        candleWidth: widget.candleWidth,
                        indicatorTime: currentCandle?.endDate,
                        index: widget.index,
                      ),
                      Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              child: Stack(
                                children: [
                                  PriceColumn(
                                    style: widget.style,
                                    low: candlesLowPrice,
                                    high: candlesHighPrice,
                                    width: constraints.maxWidth,
                                    chartHeight: chartHeight,
                                    lastCandle: widget.candles[
                                        widget.index < 0 ? 0 : widget.index],
                                    onScale: (delta) {
                                      if (manualScaleHigh == null) {
                                        manualScaleHigh = candlesHighPrice;
                                        manualScaleLow = candlesLowPrice;
                                      }
                                      setState(() {
                                        double deltaPrice = delta /
                                            chartHeight *
                                            (manualScaleHigh! -
                                                manualScaleLow!);
                                        manualScaleHigh =
                                            manualScaleHigh! + deltaPrice;
                                        manualScaleLow =
                                            manualScaleLow! - deltaPrice;
                                      });
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          clipBehavior: widget.clip,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: widget.style.borderColor,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: AnimatedPadding(
                                            duration:
                                                Duration(milliseconds: 300),
                                            padding: EdgeInsets.symmetric(
                                                vertical:
                                                    MAIN_CHART_VERTICAL_PADDING),
                                            child: RepaintBoundary(
                                              child: Stack(
                                                children: [
                                                  MainWindowIndicatorWidget(
                                                    candles: widget.candles,
                                                    indicatorDatas: widget
                                                        .mainWindowDataContainer
                                                        .indicatorComponentData,
                                                    indicatorFills: widget
                                                        .mainWindowDataContainer
                                                        .fill,
                                                    index: widget.index,
                                                    candleWidth:
                                                        widget.candleWidth,
                                                    low: low,
                                                    high: high,
                                                    drawing:
                                                        widget.drawing.first,
                                                  ),
                                                  CandleStickWidget(
                                                    candles: widget.candles,
                                                    candleWidth:
                                                        widget.candleWidth,
                                                    index: widget.index,
                                                    high: high,
                                                    low: low,
                                                    bearColor: widget
                                                        .style.primaryBear,
                                                    bullColor: widget
                                                        .style.primaryBull,
                                                    onChartPanStart:
                                                        widget.onChartPanStart,
                                                    drawing:
                                                        widget.drawing.first,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: PRICE_BAR_WIDTH,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child: Row(
                          //     children: [
                          //       Expanded(
                          //         child: Container(
                          //           decoration: BoxDecoration(
                          //             border: Border(
                          //               right: BorderSide(
                          //                 color: widget.style.borderColor,
                          //                 width: 1,
                          //               ),
                          //             ),
                          //           ),
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(top: 10.0),
                          //             child: VolumeWidget(
                          //               candles: widget.candles,
                          //               barWidth: widget.candleWidth,
                          //               index: widget.index,
                          //               high:
                          //                   HelperFunctions.getRoof(volumeHigh),
                          //               bearColor: widget.style.secondaryBear,
                          //               bullColor: widget.style.secondaryBull,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //       SizedBox(
                          //         child: Column(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             SizedBox(
                          //               height: DATE_BAR_HEIGHT,
                          //               child: Center(
                          //                 child: Row(
                          //                   children: [
                          //                     Text(
                          //                       "-${HelperFunctions.addMetricPrefix(HelperFunctions.getRoof(volumeHigh))}",
                          //                       style: TextStyle(
                          //                         color:
                          //                             widget.style.borderColor,
                          //                         fontSize: 12,
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //         width: PRICE_BAR_WIDTH,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       SizedBox(
                          //         height: DATE_BAR_HEIGHT,
                          //         child: Center(
                          //           child: Row(
                          //             children: [
                          //               // Text(
                          //               //   "-${HelperFunctions.addMetricPrefix(HelperFunctions.getRoof(volumeHigh))}",
                          //               //   style: TextStyle(
                          //               //     color:
                          //               //     widget.style.borderColor,
                          //               //     fontSize: 12,
                          //               //   ),
                          //               // ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          //   width: PRICE_BAR_WIDTH,
                          // ),
                          for (int i = 0;
                              i < widget.subWindowDataContainer.data.length;
                              i++)
                            Expanded(
                              flex: 1,
                              child: buildRow(i, inRangeCandles),
                            ),
                          SizedBox(
                            height: DATE_BAR_HEIGHT,
                          ),
                        ],
                      ),
                      longPressY != null
                          ? Positioned(
                              top: longPressY!-10,
                              child: Row(
                                children: [
                                  DashLine(
                                    length: maxWidth,
                                    color: widget.style.borderColor,
                                    direction: Axis.horizontal,
                                    thickness: 0.5,
                                  ),
                                  Container(
                                    color: widget
                                        .style.hoverIndicatorBackgroundColor,
                                    child: Center(
                                      child: Text(
                                        buildLongPress2Percent(
                                            maxHeight,
                                            longPressY,
                                            widget.index,
                                            widget.candles,
                                            inRangeCandles,
                                            high,
                                            low),
                                        style: TextStyle(
                                          color:
                                              widget.style.secondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    width: PRICE_BAR_WIDTH,
                                    height: 20,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      longPressX != null
                          ? Positioned(
                              child: Container(
                                width: widget.candleWidth,
                                height: maxHeight,
                                color: widget.style.mobileCandleHoverColor,
                              ),
                              right: (maxWidth - longPressX!) ~/
                                      widget.candleWidth *
                                      widget.candleWidth +
                                  PRICE_BAR_WIDTH,
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(right: 50, bottom: 20),
                        child: GestureDetector(
                          onScaleEnd: (_) {
                            widget.onPanEnd();
                          },
                          onScaleUpdate: (details) {
                            if (details.scale == 1) {
                              widget.onHorizontalDragUpdate(
                                  details.focalPoint.dx);
                              setState(() {
                                if (manualScaleHigh != null) {
                                  double deltaPrice =
                                      details.focalPointDelta.dy /
                                          chartHeight *
                                          (manualScaleHigh! - manualScaleLow!);
                                  manualScaleHigh =
                                      manualScaleHigh! + deltaPrice;
                                  manualScaleLow = manualScaleLow! + deltaPrice;
                                }
                              });
                            }
                            widget.onScaleUpdate(pow(details.scale, 1 / 100));
                          },
                          onScaleStart: (details) {
                            widget.onPanDown(details.localFocalPoint.dx);
                          },
                          onLongPressStart: (LongPressStartDetails details) {
                            if (widget.isDrawing) {
                              int index =
                                  (((maxWidth - details.localPosition.dx) /
                                              widget.candleWidth) +
                                          widget.index)
                                      .floor();
                              double price = double.parse(
                                  HelperFunctions.priceToString(high -
                                      (details.localPosition.dy- 20) /
                                          (maxHeight * 0.75 - 40) *
                                          (high - low)));
                              if (widget.onChartPanStart != null) {
                                widget.onChartPanStart!(CandlePosition(
                                    candle: widget.candles.getOrNull(index),
                                    index: index,
                                    x: details.localPosition.dx +
                                        index * widget.candleWidth,
                                    y: details.localPosition.dy,
                                    date: widget.candles[index].startDate,
                                    price: price));
                              }
                            }
                            setState(() {
                              longPressX = details.localPosition.dx;
                              longPressY = details.localPosition.dy;
                            });
                          },
                          behavior: HitTestBehavior.translucent,
                          onLongPressMoveUpdate:
                              (LongPressMoveUpdateDetails details) {
                            if (widget.isDrawing) {
                              int index =
                                  (((maxWidth - details.localPosition.dx) /
                                              widget.candleWidth) +
                                          widget.index)
                                      .floor();
                              double price = double.parse(
                                  HelperFunctions.priceToString(high -
                                      (details.localPosition.dy- 20) /
                                          (maxHeight * 0.75 - 40) *
                                          (high - low)));
                              if (widget.onChartPanUpadte != null) {
                                widget.onChartPanUpadte!(CandlePosition(
                                    candle: widget.candles.getOrNull(index),
                                    index: index,
                                    x: details.localPosition.dx +
                                        index * widget.candleWidth,
                                    y: details.localPosition.dy,
                                    date: widget.candles[index].startDate,
                                    price: price));
                              }
                            }
                            setState(() {
                              longPressX = details.localPosition.dx;
                              longPressY = details.localPosition.dy;
                            });
                          },
                          onLongPressEnd: (details) {
                            if (widget.isDrawing) {
                              int index =
                                  (((maxWidth - details.localPosition.dx) /
                                              widget.candleWidth) +
                                          widget.index)
                                      .floor();
                              double price = double.parse(
                                  HelperFunctions.priceToString(high -
                                      (details.localPosition.dy- 20) /
                                          (maxHeight *
                                                  (3 /
                                                      (3 +
                                                          widget.subIndicator
                                                              .length)) -
                                              40) *
                                          (high - low)));
                              if (widget.onChartPanEnd != null) {
                                widget.onChartPanEnd!(CandlePosition(
                                    candle: widget.candles.getOrNull(index),
                                    index: index,
                                    x: details.localPosition.dx +
                                        index * widget.candleWidth,
                                    y: details.localPosition.dy,
                                    date: widget.candles[index].startDate,
                                    price: price));
                              }
                            }
                            setState(() {
                              longPressX = null;
                              longPressY = null;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        child: TopPanel(
                            style: widget.style,
                            onRemoveIndicator: widget.onRemoveIndicator,
                            currentCandle: currentCandle,
                            indicators:
                                widget.mainWindowDataContainer.indicators,
                            toggleIndicatorVisibility: (indicatorName) {
                              setState(() {
                                widget.mainWindowDataContainer
                                    .toggleIndicatorVisibility(indicatorName);
                              });
                              // widget.indicatorUpdated(
                              //     0, widget.mainWindowDataContainer.indicators);
                            },
                            unvisibleIndicators: widget
                                .mainWindowDataContainer.unvisibleIndicators,
                            indicatorUpdateed: (i, d) {
                              widget.indicatorUpdated(i, d);
                            }),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: PRICE_BAR_WIDTH,
                        height: 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            primary: widget.style.hoverIndicatorBackgroundColor,
                          ),
                          child: Text("Auto"),
                          onPressed: manualScaleHigh == null
                              ? null
                              : () {
                                  setState(() {
                                    manualScaleHigh = null;
                                    manualScaleLow = null;
                                  });
                                },
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Row buildRow(int i, List<Candle> inRangeCandles) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: widget.style.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: SubIndicatorWidget(
                onSetting: widget.onSubIndicatorSettingPressed,
                candles: widget.candles,
                indicatorDatas: widget.subWindowDataContainer.data
                    .where((element) =>
                        element.parentIndicator.name ==
                        widget.subIndicator[i].name)
                    .toList(),
                indicatorData: widget.subWindowDataContainer,
                index: widget.index,
                barWidth: widget.candleWidth,
                low: widget.subIndicator[i].min!(
                    widget.index, widget.candles, inRangeCandles),
                high: widget.subIndicator[i].max!(
                    widget.index, widget.candles, inRangeCandles),
                drawing: widget.drawing.first,
                indicator: widget.subIndicator[i],
              ),
            ),
          ),
        ),
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: DATE_BAR_HEIGHT,
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        "${HelperFunctions.addMetricPrefix(widget.subIndicator[i].max!(widget.index, widget.candles, inRangeCandles).toDouble())}",
                        style: TextStyle(
                          color: widget.style.borderColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          width: PRICE_BAR_WIDTH,
        ),
      ],
    );
  }

  String buildLongPress2Percent(double maxHeight, double? longPressY, int index,
      List<Candle> candles, List<Candle> inRangeCandles, high, low) {
    var div = 1 / (3 + widget.subIndicator.length);
    if (longPressY! < (maxHeight) * 3 * div) {
      double chartHeight = (maxHeight-DATE_BAR_HEIGHT) * 3 *div;
      return HelperFunctions.priceToString((chartHeight -longPressY+5)/ (chartHeight) * (high - low) +low);
    }

    for (int i = 0; i < widget.subIndicator.length; i++) {
      if (longPressY> (maxHeight-DATE_BAR_HEIGHT) * (3 + i) * div &&
          longPressY < (maxHeight-DATE_BAR_HEIGHT) * (4 + i) * div) {
        var h = widget.subIndicator[i].max!(index, candles, inRangeCandles);
        var l = widget.subIndicator[i].min!(index, candles, inRangeCandles);

        var startP = (3 + i) * div * (maxHeight -DATE_BAR_HEIGHT);
        var endP = (4 + i) * div * (maxHeight-DATE_BAR_HEIGHT);
        var range = endP - startP;
        var v = (longPressY - 10 - startP) / range;
        // return ;

        return HelperFunctions.addMetricPrefix(((1 - v) * (h - l)) + l);
      }
    }
    return "";
  }
}
