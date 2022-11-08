import 'package:candlesticks/src/models/color_with_calculator_value.dart';
import 'package:candlesticks/src/models/sub_indicator.dart';
import 'package:candlesticks/src/utils/util.dart';

import 'candle.dart';

class SubIndicatorComponentData {
  final String name;
  late List<List<ColorWithCalculatorValue?>> values = [];
  final SubIndicator parentIndicator;

  SubIndicatorComponentData(this.parentIndicator, this.name);

  bool visible = true;
}

class SubIndicatorDataContainer {
  List<List<num>> highs = [];
  List<List<num>> lows = [];
  List<SubIndicator> subIndicators;
  List<SubIndicatorComponentData> data = [];

  SubIndicatorDataContainer(this.subIndicators, List<Candle> candles) {
    for (int i = 0; i < subIndicators.length; i++) {
      var indicator = subIndicators[i];
      lows.add([]);
      highs.add([]);

      data.add(SubIndicatorComponentData(indicator, indicator.name));
      for (int c = 0; c < candles.length; c++) {
        data[i].values.add(indicator.calculatorWithStyle(c, candles));
        var max =
            (data[i].values[c].map((e) => e?.value as num).toList()).max();
        var min =
            (data[i].values[c].map((e) => e?.value as num).toList()).min();
        lows[i].insert(c, min);
        highs[i].insert(c, max);
      }
    }
  }
}
