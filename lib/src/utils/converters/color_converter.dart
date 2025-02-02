import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color object) => object.value;
}
