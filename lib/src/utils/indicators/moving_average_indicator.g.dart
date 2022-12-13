// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moving_average_indicator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovingAverageIndicator _$MovingAverageIndicatorFromJson(
        Map<String, dynamic> json) =>
    MovingAverageIndicator(
      length: json['length'] as int,
      color: _$JsonConverterFromJson<int, dynamic>(
          json['color'], const ColorConverter().fromJson),
      label: json['label'] as String?,
      name: json['name'] as String,
    )
      ..visible = json['visible'] as bool
      ..koreanName = json['koreanName'] as String;

Map<String, dynamic> _$MovingAverageIndicatorToJson(
        MovingAverageIndicator instance) =>
    <String, dynamic>{
      'label': instance.label,
      'visible': instance.visible,
      'length': instance.length,
      'color': const ColorConverter().toJson(instance.color),
      'koreanName': instance.koreanName,
      'name': instance.name,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
