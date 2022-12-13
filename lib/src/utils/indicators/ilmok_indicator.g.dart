// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ilmok_indicator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IchimokuIndicator _$IchimokuIndicatorFromJson(Map<String, dynamic> json) =>
    IchimokuIndicator(
      short: json['short'] as int,
      middle: json['middle'] as int,
      long: json['long'] as int,
      shortLineColor: _$JsonConverterFromJson<int, dynamic>(
          json['shortLineColor'], const ColorConverter().fromJson),
      middleLineColor: _$JsonConverterFromJson<int, dynamic>(
          json['middleLineColor'], const ColorConverter().fromJson),
      longLineColor: _$JsonConverterFromJson<int, dynamic>(
          json['longLineColor'], const ColorConverter().fromJson),
      leadLine1Color: _$JsonConverterFromJson<int, dynamic>(
          json['leadLine1Color'], const ColorConverter().fromJson),
      leadLine2Color: _$JsonConverterFromJson<int, dynamic>(
          json['leadLine2Color'], const ColorConverter().fromJson),
      label: json['label'] as String?,
      name: json['name'] as String,
    )
      ..visible = json['visible'] as bool
      ..koreanName = json['koreanName'] as String;

Map<String, dynamic> _$IchimokuIndicatorToJson(IchimokuIndicator instance) =>
    <String, dynamic>{
      'label': instance.label,
      'visible': instance.visible,
      'koreanName': instance.koreanName,
      'short': instance.short,
      'middle': instance.middle,
      'long': instance.long,
      'shortLineColor': const ColorConverter().toJson(instance.shortLineColor),
      'longLineColor': const ColorConverter().toJson(instance.longLineColor),
      'middleLineColor':
          const ColorConverter().toJson(instance.middleLineColor),
      'leadLine1Color': const ColorConverter().toJson(instance.leadLine1Color),
      'leadLine2Color': const ColorConverter().toJson(instance.leadLine2Color),
      'name': instance.name,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
