import 'dart:ui';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/utils/converters/color_converter.dart';
import 'package:json_annotation/json_annotation.dart';


part 'ilmok_indicator.g.dart';


@JsonSerializable()
class IchimokuIndicator extends Indicator {
  String koreanName = "일목균형표";

  int short;
  int middle;
  int long;
  @ColorConverter()
  Color shortLineColor;
  @ColorConverter()
  Color longLineColor;
  @ColorConverter()
  Color middleLineColor;
  @ColorConverter()
  Color leadLine1Color;
  @ColorConverter()
  Color leadLine2Color;

  String name;

  factory IchimokuIndicator.fromJson(Map<String, dynamic> json) =>
      _$IchimokuIndicatorFromJson(json);

  Map<String, dynamic> toJson() => _$IchimokuIndicatorToJson(this);

  IchimokuIndicator(
      {required int this.short,
      required int this.middle,
      required int this.long,
      required Color this.shortLineColor,
      required Color this.middleLineColor,
      required Color this.longLineColor,
      required Color this.leadLine1Color,
      required Color this.leadLine2Color,
      String? label, required this.name})
      : super(
            name: name,
            dependsOnNPrevCandles: middle,
            calculator: (index, candles) {
              double? conversionLine = null;
              double? baseline = null;
              double? displacement = null;
              double? leadline1 = null;
              double? leadline2 = null;

              if (candles.length - index >= short - 1) {
                var sublist = candles.sublist(
                    index,
                    candles.length < index + (short - 1)
                        ? candles.length
                        : index + (short - 1));
                var high = sublist.map<double>((e) => e.high).toList().max();
                var low = sublist.map<double>((e) => e.low).toList().min();
                conversionLine = (high + low) / 2;
              }
              if (candles.length - index >= middle - 1) {
                var sublist = candles.sublist(
                    index,
                    candles.length < index + (middle - 1)
                        ? candles.length
                        : index + (middle - 1));
                var high = sublist.map<double>((e) => e.high).toList().max();
                var low = sublist.map<double>((e) => e.low).toList().min();
                baseline = (high + low) / 2;

                // 선행스팬 1
              } else {
                var sublist = candles.sublist(index, index + (middle - 1));
                var high = sublist.map<double>((e) => e.high).toList().max();
                var low = sublist.map<double>((e) => e.low).toList().min();
                baseline = (high + low) / 2;
              }

              if (index > (middle + 1))
                displacement = (candles[index - (middle - 1)].close);
              else
                displacement = null;

              if (candles.length - index > middle * 2) {
                var sublist = candles.sublist(
                  index + middle,
                  index + middle * 2,
                );
                var sublist2 = candles.sublist(
                  index + middle,
                  index + middle + short,
                );
                var high = sublist.map<double>((e) => e.high).toList().max();
                var low = sublist.map<double>((e) => e.low).toList().min();

                var high2 = sublist2.map<double>((e) => e.high).toList().max();
                var low2 = sublist2.map<double>((e) => e.low).toList().min();
                var middleBeforeConversionLine = (high + low) / 2;
                var middleBeforeBaseLine = (high2 + low2) / 2;
                leadline1 =
                    (middleBeforeConversionLine + middleBeforeBaseLine) / 2;
              }

              if (candles.length - index > long + middle) {
                var range =
                    candles.sublist(index + middle, index + middle + long);

                var high = range.map((x) => x.high).toList().max();
                var low = range.map((x) => x.low).toList().min();

                leadline2 = (high + low) / 2;
              }
              return [
                conversionLine,
                baseline,
                displacement,
                leadline1,
                leadline2
              ];
            },
            indicatorComponentsStyles: [
              IndicatorStyle(name: "전환선", bullColor: shortLineColor),
              IndicatorStyle(name: "기준선", bullColor: middleLineColor),
              IndicatorStyle(name: "후행스팬", bullColor: longLineColor),
              IndicatorStyle(name: "선행스팬 1", bullColor: leadLine1Color),
              IndicatorStyle(name: "선행스팬 2", bullColor: leadLine2Color),
            ],
            indicatorFill: [
              IndicatorStyle(
                  name: "cloud1",
                  bullColor: leadLine1Color,
                  bearColor: leadLine2Color,
                  startIndex: 3,
                  endIndex: 4),
            ],
            label: label);

}
