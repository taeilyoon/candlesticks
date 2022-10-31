import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/subIndicator_chart_type.dart';

class SubIndicator extends Indicator {
  SubIndicatorChartType chartStyle;

  List<ColorWithCalculatorValue> Function(int p1, List<Candle> p2)?
      calculatorWithStyle;

  SubIndicator(
      {required String name,
      required int dependsOnNPrevCandles,
      required List<IndicatorStyle> indicatorComponentsStyles,
      required this.chartStyle,
      required List<double?> Function(int, List<Candle>) calculator,
      List<ColorWithCalculatorValue> Function(int, List<Candle>)?
          this.calculatorWithStyle})
      : super(
            name: name,
            dependsOnNPrevCandles: dependsOnNPrevCandles,
            indicatorComponentsStyles: indicatorComponentsStyles,
            calculator: calculator);
}
