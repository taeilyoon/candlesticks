import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';

extension CandleCalulate on Candle {
  num get typicalPrice {
    return high + low + close / 3;
  }
}

na(num? n) {
  return n == null ? 0 : n;
}

extension numListExt on List<num> {
  num exponentialMovingAverage(int len, {int index = 0}) {
    var alpha = 2 / (len + 1);
    var ema = this[len+index];
    for (var i = len+index; i >= index; i--) {
      ema = alpha * this[i] + (1 - alpha) * ema;
    }
    return ema;
  }
}

class Math {
  static double Max(double a, double b) {
    return a > b ? a : b;
  }
  static double Min(double a, double b) {
    return a < b ? a : b;
  }

  static double Abs(double a) {
    return a > 0 ? a : -a;
  }
}

extension CandleListCalulate on List<Candle> {
  trueRange(int index) {
    var truerange = 0.0;
    if (index == 0) {
      truerange = this[index].high - this[index].low;
    } else {
      truerange = max(
          this[index].high - this[index].low,
          max((this[index].high - this[index + 1].close).abs(),
              (this[index + 1].close - this[index + 1].low).abs()));
    }
    return truerange;
  }

  num taChange(int index, num Function(Candle e) mapper) {
    return na(mapper(this[index])) - na(mapper(this[index - 1]));
  }

  num hlcMovingAverage(int periods, {int index = 0}) {
    var avg = 0.0;
    this.skip(index).take(periods).forEach((element) {
      avg += element.typicalPrice;
    });
    return avg / periods;
  }

  num simpleMovingAverage(int periods, {int index = 0}) {
    var avg = 0.0;
    this.skip(0).take(periods).toList().asMap().forEach((i, element) {
      avg += element.close * (periods - i) / periods;
    });
    return avg / periods * 2;
  }

  num weightMovingAverage(int periods, {int index = 0}) {
    var avg = 0.0;
    this.skip(0).take(periods).toList().asMap().forEach((i, element) {
      avg += element.close * (periods.sigma - i);
    });
    return avg / periods;
  }

  num sum(num Function(Candle c, int index) loop,
      {required int periods, int index = 0}) {
    var avg = 0.0;
    this.skip(index).take(periods).toList().asMap().forEach((i, element) {
      avg += loop(this[i + index], index);
    });
    return avg / periods;
  }
}

extension intExt on int {
  int get sigma => (2 * this + 1 / 2).floor();
}

extension ListNumExt<T extends num> on List<T> {
  T max() {
    if (length == 0) {
      return 0.0 as T;
    }
    return reduce((curr, next) => curr > next ? curr : next);
  }

  T min() {
    if (length == 0) {
      return 0.0 as T;
    }
    return reduce((curr, next) => curr < next ? curr : next);
  }

  T ema() {
    return this.first;
  }

  T sma() {
    return reduce((value, element) {
      return value + element as T;
    });
  }
}

extension ListExt<T> on List<T> {
  void addNotNull(T? value) {
    if (value == null) return;
    add(value);
  }

  T? get firstOrNull {
    if (length == 0)
      return null;
    else
      return first;
  }

  T? firstWhereOrNull(
    bool test(T element),
  ) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  T? getOrNull(int i) {
    if (length < i) {
      return null;
    } else {
      return this[i];
    }
  }
}

extension DateTimeExt on DateTime {
  isAfterOrSame() {}
}

num nz(num? number) {
  if (number?.isNaN != false) {
    return 0;
  }
  return number!;
}
