// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bollinger_bands_indicator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BollingerBandsIndicator _$BollingerBandsIndicatorFromJson(
        Map<String, dynamic> json) =>
    BollingerBandsIndicator(
      length: json['length'] as int,
      stdDev: json['stdDev'] as int,
      upperColor: _$JsonConverterFromJson<int, dynamic>(
          json['upperColor'], const ColorConverter().fromJson),
      basisColor: _$JsonConverterFromJson<int, dynamic>(
          json['basisColor'], const ColorConverter().fromJson),
      lowerColor: _$JsonConverterFromJson<int, dynamic>(
          json['lowerColor'], const ColorConverter().fromJson),
      label: json['label'] as String?,
    )
      ..visible = json['visible'] as bool
      ..koreanName = json['koreanName'] as String;

Map<String, dynamic> _$BollingerBandsIndicatorToJson(
        BollingerBandsIndicator instance) =>
    <String, dynamic>{
      'label': instance.label,
      'visible': instance.visible,
      'koreanName': instance.koreanName,
      'basisColor': const ColorConverter().toJson(instance.basisColor),
      'stdDev': instance.stdDev,
      'length': instance.length,
      'upperColor': const ColorConverter().toJson(instance.upperColor),
      'lowerColor': const ColorConverter().toJson(instance.lowerColor),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
