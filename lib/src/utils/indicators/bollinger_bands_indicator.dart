import 'dart:math' as math;
import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/utils/converters/color_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bollinger_bands_indicator.g.dart';


@JsonSerializable()
class BollingerBandsIndicator extends Indicator {

  @ColorConverter()
  Color basisColor;
  int stdDev;
  int length;
  @ColorConverter()
  Color upperColor;
  @ColorConverter()
  Color lowerColor;



  factory BollingerBandsIndicator.fromJson(Map<String, dynamic> json) =>
      _$BollingerBandsIndicatorFromJson(json);

  Map<String, dynamic> toJson() => _$BollingerBandsIndicatorToJson(this);

  BollingerBandsIndicator(
      {required int this.length,
      required int this.stdDev,
      required Color this.upperColor,
      required Color this.basisColor,
      required Color this.lowerColor,
      String? label})
      : super(
            name: "BB " + length.toString(),
            dependsOnNPrevCandles: length,
            calculator: (index, candles) {
              double sum = 0;
              for (int i = index; i < index + length; i++) {
                sum += candles[i].close;
              }
              final average = sum / length;

              num sumOfSquaredDiffFromMean = 0;
              for (int i = index; i < index + length; i++) {
                final squareDiffFromMean =
                    math.pow(candles[i].close - average, 2);
                sumOfSquaredDiffFromMean += squareDiffFromMean;
              }

              final variance = sumOfSquaredDiffFromMean / length;

              final standardDeviation = math.sqrt(variance);

              return [
                average + standardDeviation * stdDev,
                average,
                average - standardDeviation * stdDev
              ];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "upper", bullColor: upperColor),
              IndicatorStyle(name: "basis", bullColor: basisColor),
              IndicatorStyle(name: "lower", bullColor: lowerColor)
            ],
            label: label);
}
