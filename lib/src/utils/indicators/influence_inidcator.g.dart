// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'influence_inidcator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfurenceIndicator _$InfurenceIndicatorFromJson(Map<String, dynamic> json) =>
    InfurenceIndicator(
      shortPeriod: json['shortPeriod'] as int,
      midPeriod: json['midPeriod'] as int,
      centerColor: _$JsonConverterFromJson<int, dynamic>(
              json['centerColor'], const ColorConverter().fromJson) ??
          Colors.blue,
      centerChange: _$JsonConverterFromJson<int, dynamic>(
              json['centerChange'], const ColorConverter().fromJson) ??
          Colors.red,
      label: json['label'] as String?,
      name: json['name'] as String? ?? "세력 중심선",
    )
      ..visible = json['visible'] as bool
      ..koreanName = json['koreanName'] as String;

Map<String, dynamic> _$InfurenceIndicatorToJson(InfurenceIndicator instance) =>
    <String, dynamic>{
      'label': instance.label,
      'visible': instance.visible,
      'koreanName': instance.koreanName,
      'shortPeriod': instance.shortPeriod,
      'midPeriod': instance.midPeriod,
      'centerColor': const ColorConverter().toJson(instance.centerColor),
      'centerChange': const ColorConverter().toJson(instance.centerChange),
      'name': instance.name,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
