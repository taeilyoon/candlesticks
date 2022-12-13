import 'dart:io' show Platform;
import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/drawing.dart';
import 'package:candlesticks/src/models/main_window_indicator.dart';
import 'package:candlesticks/src/models/sub_window_indicator.dart';
import 'package:candlesticks/src/widgets/desktop_chart.dart';
import 'package:candlesticks/src/widgets/mobile_chart.dart';
import 'package:candlesticks/src/widgets/toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/sub_indicator.dart';

enum ChartAdjust {
  /// Will adjust chart size by max and min value from visible area
  visibleRange,

  /// Will adjust chart size by max and min value from the whole data
  fullRange
}

class CandlePosition {
  final Candle? candle;
  final int index;
  final double x;
  final double y;

  final double price;
  final DateTime? date;
  CandlePosition(
      {this.candle,
      required this.index,
      required this.x,
      required this.y,
      required this.price,
      required this.date});
}

typedef OnChartPanStart(CandlePosition postion);
typedef OnChartPanUpdate(CandlePosition postion);
typedef OnChartPanEnd(CandlePosition postion);

enum PriceIndicatorOption {
  recent,
  shownRecent,
  recentAndShownRecent,
}

/// StatefulWidget that holds Chart's State (index of
/// current position and candles width).
class Candlesticks extends StatefulWidget {
  /// The arrangement of the array should be such that
  /// the newest item is in position 0
  final List<Candle> candles;

  /// This callback calls when the last candle gets visible
  final Future<void> Function()? onLoadMoreCandles;

  /// List of buttons you what to add on top tool bar
  final List<ToolBarAction> actions;

  /// List of indicators to draw
  final List<Indicator>? indicators;

  /// This callback calls when ever user clicks a spcesific indicator close button (X)
  final void Function(String)? onRemoveIndicator;

  /// How chart price range will be adjusted when moving chart
  final ChartAdjust chartAdjust;

  /// Will zoom buttons be displayed in toolbar
  final bool displayZoomActions;

  /// Custom loading widget
  final Widget? loadingWidget;
  final CandleSticksStyle? style;
  final bool isDrawingMode;

  final List<SubIndicator> subIndicator;

  final OnChartPanStart? onChartPanStart;
  final OnChartPanUpdate? onChartPanUpadte;
  final OnChartPanEnd? onChartPanEnd;
  final List<List<ChartDrawing>> drawing;
  // final List<TimeOfDay> skipDateTime = [s]

  final clip;

  final PriceIndicatorOption priceIndicatorOption;
  final void Function(int index, List<Indicator> updated) indicatorUpdated;

  final Function(int index) onSubIndicatorSettingPressed;

  const Candlesticks({
    Key? key,
    required this.candles,
    this.onLoadMoreCandles,
    this.actions = const [],
    this.chartAdjust = ChartAdjust.visibleRange,
    this.displayZoomActions = true,
    this.loadingWidget,
    this.indicators,
    this.onRemoveIndicator,
    this.isDrawingMode = false,
    this.clip = Clip.hardEdge,
    this.onChartPanStart,
    this.onChartPanUpadte,
    this.onChartPanEnd,
    this.subIndicator = const [],
    this.style,
    this.drawing = const [[], [], []],
    this.priceIndicatorOption = PriceIndicatorOption.shownRecent,
    required this.indicatorUpdated,
    required this.onSubIndicatorSettingPressed,
  })  : assert(candles.length == 0 || candles.length > 1,
            "Please provide at least 2 candles"),
        super(key: key);

  @override
  _CandlesticksState createState() => _CandlesticksState();
}

class _CandlesticksState extends State<Candlesticks> {
  /// index of the newest candle to be displayed
  /// changes when user scrolls along the chart
  int index = -10;
  double lastX = 0;
  int lastIndex = -10;

  /// candleWidth controls the width of the single candles.
  ///  range: [2...10]
  double candleWidth = 6;

  /// true when widget.onLoadMoreCandles is fetching new candles.
  bool isCallingLoadMore = false;

  MainWindowDataContainer? mainWindowDataContainer;
  SubIndicatorDataContainer? subWindowDataContainer;

  @override
  void initState() {
    super.initState();
    if (widget.candles.length == 0) {
      return;
    }
    if (mainWindowDataContainer == null) {
      mainWindowDataContainer =
          MainWindowDataContainer(widget.indicators ?? [], widget.candles);
    }

    if (subWindowDataContainer == null) {
      subWindowDataContainer =
          SubIndicatorDataContainer(widget.subIndicator , widget.candles);
    }
  }

  @override
  void didUpdateWidget(covariant Candlesticks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.candles.length == 0) {
      return;
    }
    if (mainWindowDataContainer == null) {
      mainWindowDataContainer =
          MainWindowDataContainer(widget.indicators ?? [], widget.candles);
    } else {
      final currentIndicators = widget.indicators ?? [];
      final oldIndicators = oldWidget.indicators ?? [];
      if (currentIndicators.length == oldIndicators.length) {
        for (int i = 0; i < currentIndicators.length; i++) {
          // if (currentIndicators[i] == oldIndicators[i]) {
          // continue;
          // } else {
          mainWindowDataContainer =
              MainWindowDataContainer(widget.indicators ?? [], widget.candles);
          return;
          // }
        }
      } else {
        mainWindowDataContainer =
            MainWindowDataContainer(widget.indicators ?? [], widget.candles);
        return;
      }
      try {
        mainWindowDataContainer!.tickUpdate(widget.candles);
      } catch (_) {
        mainWindowDataContainer =
            MainWindowDataContainer(widget.indicators ?? [], widget.candles);
      }
      // TODO Sub too;

      try {
        subWindowDataContainer!.tickUpdate(widget.candles);
      } catch (_) {
        // subWindowDataContainer =
            // SubIndicatorDataContainer(widget.indicators ?? [], widget.candles);
      }


    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        (Theme.of(context).brightness == Brightness.dark
            ? CandleSticksStyle.dark()
            : CandleSticksStyle.light());
    return Column(
      children: [
        if (widget.displayZoomActions == true || widget.actions.isNotEmpty) ...[
          ToolBar(
            color: style.toolBarColor,
            children: [
              if (widget.displayZoomActions) ...[
                ToolBarAction(
                  onPressed: () {
                    setState(() {
                      candleWidth -= 2;
                      candleWidth = max(candleWidth, 2);
                    });
                  },
                  child: Icon(
                    Icons.remove,
                    color: style.borderColor,
                  ),
                ),
                ToolBarAction(
                  onPressed: () {
                    setState(() {
                      candleWidth += 2;
                      candleWidth = min(candleWidth, 20);
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: style.borderColor,
                  ),
                ),
              ],
              ...widget.actions
            ],
          ),
        ],
        if (widget.candles.length == 0 || mainWindowDataContainer == null)
          Expanded(
            child: Center(
              child: widget.loadingWidget ??
                  CircularProgressIndicator(color: style.loadingColor),
            ),
          )
        else
          Expanded(
            child: TweenAnimationBuilder(
              tween: Tween(begin: 6.toDouble(), end: candleWidth),
              duration: Duration(milliseconds: 120),
              builder: (_, double width, __) {
                return MobileChart(
                  onSubIndicatorSettingPressed:
                      widget.onSubIndicatorSettingPressed,
                  style: style,
                  onRemoveIndicator: widget.onRemoveIndicator,
                  mainWindowDataContainer: mainWindowDataContainer!,
                  subWindowDataContainer: subWindowDataContainer!,
                  chartAdjust: widget.chartAdjust,
                  isDrawing: widget.isDrawingMode,
                  drawing: widget.drawing,
                  clip: widget.clip,
                  subIndicator: widget.subIndicator,
                  priceIndicatorOption: widget.priceIndicatorOption,
                  onScaleUpdate: (double scale) {
                    scale = max(0.90, scale);
                    scale = min(1.1, scale);
                    setState(() {
                      candleWidth *= scale;
                      candleWidth = min(candleWidth, 20);
                      candleWidth = max(candleWidth, 2);
                    });
                  },
                  onPanEnd: () {
                    lastIndex = index;
                  },
                  onHorizontalDragUpdate: (double x) {
                    setState(() {
                      x = x - lastX;
                      index = lastIndex + x ~/ candleWidth;
                      index = max(index, -10);
                      index = min(index, widget.candles.length - 1);
                    });
                  },
                  onPanDown: (double value) {
                    lastX = value;
                    lastIndex = index;
                  },
                  onReachEnd: () {
                    if (isCallingLoadMore == false &&
                        widget.onLoadMoreCandles != null) {
                      isCallingLoadMore = true;
                      widget.onLoadMoreCandles!().then((_) {
                        isCallingLoadMore = false;
                      });
                    }
                  },
                  indicatorUpdated: widget.indicatorUpdated,
                  candleWidth: width,
                  candles: widget.candles,
                  index: index,
                  onChartPanStart: widget.onChartPanStart,
                  onChartPanUpadte: widget.onChartPanUpadte,
                  onChartPanEnd: widget.onChartPanEnd,
                );

                if (kIsWeb ||
                    Platform.isMacOS ||
                    Platform.isWindows ||
                    Platform.isLinux) {
                  return DesktopChart(
                    style: style,
                    onRemoveIndicator: widget.onRemoveIndicator,
                    mainWindowDataContainer: mainWindowDataContainer!,
                    chartAdjust: widget.chartAdjust,
                    onScaleUpdate: (double scale) {
                      scale = max(0.90, scale);
                      scale = min(1.1, scale);
                      setState(() {
                        candleWidth *= scale;
                        candleWidth = min(candleWidth, 20);
                        candleWidth = max(candleWidth, 2);
                      });
                    },
                    onChartPanStart: widget.onChartPanStart,
                    onChartPanUpadte: widget.onChartPanUpadte,
                    onChartPanEnd: widget.onChartPanEnd,
                    onPanEnd: () {
                      lastIndex = index;
                    },
                    drawing: widget.drawing,
                    onHorizontalDragUpdate: (double x) {
                      if (widget.isDrawingMode) {
                      } else {
                        setState(() {
                          x = x - lastX;
                          index = lastIndex + x ~/ candleWidth;
                          index = max(index, -10);
                          index = min(index, widget.candles.length - 1);
                        });
                      }
                    },
                    onPanDown: (double value) {
                      lastX = value;
                      lastIndex = index;
                    },
                    onReachEnd: () {
                      if (isCallingLoadMore == false &&
                          widget.onLoadMoreCandles != null) {
                        isCallingLoadMore = true;
                        widget.onLoadMoreCandles!().then((_) {
                          isCallingLoadMore = false;
                        });
                      }
                    },
                    candleWidth: width,
                    candles: widget.candles,
                    index: index,
                    isDrawing: widget.isDrawingMode,
                  );
                } else {
                  // return MobileChart(
                  //   style: style,
                  //   onRemoveIndicator: widget.onRemoveIndicator,
                  //   mainWindowDataContainer: mainWindowDataContainer!,
                  //   chartAdjust: widget.chartAdjust,
                  //   isDrawing: widget.isDrawingMode,
                  //   drawing: widget.drawing,
                  //   clip: widget.clip,
                  //   priceIndicatorOption: widget.priceIndicatorOption,
                  //   onScaleUpdate: (double scale) {
                  //     scale = max(0.90, scale);
                  //     scale = min(1.1, scale);
                  //     setState(() {
                  //       candleWidth *= scale;
                  //       candleWidth = min(candleWidth, 20);
                  //       candleWidth = max(candleWidth, 2);
                  //     });
                  //   },
                  //   onPanEnd: () {
                  //     lastIndex = index;
                  //   },
                  //   onHorizontalDragUpdate: (double x) {
                  //     setState(() {
                  //       x = x - lastX;
                  //       index = lastIndex + x ~/ candleWidth;
                  //       index = max(index, -10);
                  //       index = min(index, widget.candles.length - 1);
                  //     });
                  //   },
                  //   onPanDown: (double value) {
                  //     lastX = value;
                  //     lastIndex = index;
                  //   },
                  //   onReachEnd: () {
                  //     if (isCallingLoadMore == false &&
                  //         widget.onLoadMoreCandles != null) {
                  //       isCallingLoadMore = true;
                  //       widget.onLoadMoreCandles!().then((_) {
                  //         isCallingLoadMore = false;
                  //       });
                  //     }
                  //   },
                  //   indicatorUpdated: widget.indicatorUpdated,
                  //   candleWidth: width,
                  //   candles: widget.candles,
                  //   index: index,
                  //   onChartPanStart: widget.onChartPanStart,
                  //   onChartPanUpadte: widget.onChartPanUpadte,
                  //   onChartPanEnd: widget.onChartPanEnd,
                  // );
                }
              },
            ),
          ),
      ],
    );
  }
}
