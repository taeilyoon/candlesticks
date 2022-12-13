import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';

class SubIndicator {
  SubIndicatorChartType chartStyle;

  List<ColorWithCalculatorValue?> Function(int p1, List<Candle> p2)
      calculatorWithStyle;
  num Function(
      int p1, List<Candle> p2, List<List<ColorWithCalculatorValue?>> p3, int start, int? end)? max;
  num Function(
      int p1, List<Candle> p2, List<List<ColorWithCalculatorValue?>> p3, int start, int end)? min;

  final String name;
  final String? label;
  final int dependsOnNPrevCandles;

  // final List<IndicatorStyle> indicatorComponentsStyles;
  // final List<IndicatorStyle> indicatorFill;

  SubIndicator(
      {required this.name,
      required this.dependsOnNPrevCandles,
      // required List<IndicatorStyle> this.indicatorComponentsStyles,
      required this.chartStyle,
      required List<double?> Function(int, List<Candle>) calculator,
      required this.calculatorWithStyle,
      // this.indicatorFill = const [],
      this.label,
      this.max,
      this.min});
}
