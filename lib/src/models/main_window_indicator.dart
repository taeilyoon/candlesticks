import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'candle.dart';
import 'package:candlesticks/candlesticks.dart';

class IndicatorComponentData {
  final String name;
  final Color color;
  final List<double?> values = [];
  final Indicator parentIndicator;
  IndicatorComponentData(this.parentIndicator, this.name, this.color);
  bool visible = true;
}

class IndicatorFillData {
  final String name;
  final Color bullColor;
  final Color bearColor;
  bool visible = true;

  final List<IndicatorComponentData> indicatorData;

  final Indicator parentIndicator;

  IndicatorFillData(this.name, this.bullColor, this.bearColor,
      this.indicatorData, this.parentIndicator);
}

class MainWindowDataContainer {
  List<IndicatorComponentData> indicatorComponentData = [];
  List<Indicator> indicators;
  List<IndicatorFillData> fill = [];
  List<double> highs = [];
  List<double> lows = [];
  List<String> unvisibleIndicators = [];
  late DateTime beginDate;
  late DateTime endDate;

  void toggleIndicatorVisibility(String indicatorName) {
    if (unvisibleIndicators.contains(indicatorName)) {
      unvisibleIndicators.remove(indicatorName);
      var s = indicators
          .where((element) => element.name == indicatorName)
          .toList()
          .firstOrNull;
      s?.visible = true;

      indicatorComponentData.forEach((element) {
        if (element.parentIndicator.name == indicatorName) {
          element.visible = true;
        }
      });
      fill.forEach((element) {
        if (element.parentIndicator.name == indicatorName) {
          element.visible = true;
        }
      });
    } else {
      unvisibleIndicators.add(indicatorName);
      var s = indicators
          .where((element) => element.name == indicatorName)
          .toList()
          .firstOrNull;
      s?.visible = false;
      indicatorComponentData.forEach((element) {
        if (element.parentIndicator.name == indicatorName) {
          element.visible = false;
        }
      });
      fill.forEach((element) {
        if (element.parentIndicator.name == indicatorName) {
          element.visible = false;
        }
      });
    }
  }

  MainWindowDataContainer(this.indicators, List<Candle> candles) {
    endDate = candles[0].endDate;
    beginDate = candles.last.endDate;
    indicators.forEach((indicator) {
      var start = indicatorComponentData.length;
      indicator.indicatorComponentsStyles.forEach((indicatorComponent) {
        indicatorComponentData.add(IndicatorComponentData(
            indicator, indicatorComponent.name, indicatorComponent.bullColor)
          ..visible = indicator.visible);
      });

      fill = [];
      indicator.indicatorFill.forEach((element) {
        fill.add(IndicatorFillData(
            element.name,
            element.bullColor,
            element.bearColor!,
            [
              indicatorComponentData[start + element.startIndex!],
              indicatorComponentData[start + element.endIndex!]
            ],
            indicator)
          ..visible = indicator.visible);
      });
    });

    highs = candles.map((e) => e.high).toList();
    lows = candles.map((e) => e.low).toList();

    indicators.forEach((indicator) {
      final List<IndicatorComponentData> containers = indicatorComponentData
          .where((element) => element.parentIndicator == indicator)
          .toList();

      for (int i = 0; i < candles.length; i++) {
        double low = lows[i];
        double high = highs[i];

        List<double?> indicatorDatas = List.generate(
            indicator.indicatorComponentsStyles.length, (index) => null);

        if (i + indicator.dependsOnNPrevCandles < candles.length) {
          indicatorDatas = indicator.calculator(i, candles);
        }

        for (int i = 0; i < indicatorDatas.length; i++) {
          containers[i].values.add(indicatorDatas[i]);
          if (indicatorDatas[i] != null) {
            low = math.min(low, indicatorDatas[i]!);
            high = math.max(high, indicatorDatas[i]!);
          }
        }
        lows[i] = low;
        highs[i] = high;
      }
    });
  }

  void tickUpdate(List<Candle> candles) {
    // update last candles

    this.indicators.forEach((parent) {
      this
          .indicatorComponentData
          .where((element) => element.parentIndicator.name == parent.name)
          .toList()
          .forEach((element) {
        element.visible = parent.visible;
        if (element.visible) {
          unvisibleIndicators.remove(element.name);
        } else {
          unvisibleIndicators.add(element.name);
        }
        indicatorComponentData.forEach((element) {
          if (element.parentIndicator.name == parent.name) {
            element.visible = parent.visible;
          }
        });

        for (var f in fill) {
          if (f.parentIndicator.name == parent.name) {
            f.visible = parent.visible;
          }
        }
      });
    });
    for (int i = 0; candles[i].endDate.compareTo(endDate) > 0; i++) {
      highs.insert(i, candles[i].high);
      lows.insert(i, candles[i].low);
      indicatorComponentData.forEach((element) {
        element.values.insert(i, null);
      });
    }
    indicators.forEach(
      (indicator) {
        final List<IndicatorComponentData> containers = indicatorComponentData
            .where((element) => element.parentIndicator == indicator)
            .toList();

        for (int i = 0; candles[i].endDate.compareTo(endDate) >= 0; i++) {
          double low = lows[i];
          double high = highs[i];

          List<double?> indicatorDatas = List.generate(
              indicator.indicatorComponentsStyles.length, (index) => null);

          if (i + indicator.dependsOnNPrevCandles < candles.length) {
            indicatorDatas = indicator.calculator(i, candles);
          }

          for (int j = 0; j < indicatorDatas.length; j++) {
            containers[j].values[i] = indicatorDatas[j];
            if (indicatorDatas[j] != null) {
              low = math.min(low, indicatorDatas[j]!);
              high = math.max(high, indicatorDatas[j]!);
            }
          }
          lows[i] = low;
          highs[i] = high;
        }
      },
    );
    endDate = candles[0].endDate;

    // update prev candles
    int firstCandleIndex = 0;
    for (int i = candles.length - 1; i >= 0; i--) {
      if (candles[i].endDate == beginDate) {
        firstCandleIndex = i;
        break;
      }
    }
    for (int i = firstCandleIndex + 1; i < candles.length; i++) {
      highs.add(candles[i].high);
      lows.add(candles[i].low);
      indicatorComponentData.forEach((element) {
        element.values.add(null);
      });
    }
    indicators.forEach(
      (indicator) {
        final List<IndicatorComponentData> containers = indicatorComponentData
            .where((element) => element.parentIndicator == indicator)
            .toList();

        // TODO
        for (int i = firstCandleIndex - indicator.dependsOnNPrevCandles + 1;
            i < candles.length;
            i++) {
          double low = lows[i];
          double high = highs[i];

          List<double?> indicatorDatas = List.generate(
              indicator.indicatorComponentsStyles.length, (index) => null);

          if (i + indicator.dependsOnNPrevCandles < candles.length) {
            indicatorDatas = indicator.calculator(i, candles);
          }

          for (int j = 0; j < indicatorDatas.length; j++) {
            containers[j].values[i] = indicatorDatas[j];
            if (indicatorDatas[j] != null) {
              low = math.min(low, indicatorDatas[j]!);
              high = math.max(high, indicatorDatas[j]!);
            }
          }
          lows[i] = low;
          highs[i] = high;
        }
      },
    );
    beginDate = candles.last.endDate;
  }
}
