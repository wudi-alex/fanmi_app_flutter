import 'dart:ui';
import 'package:flutter/material.dart';

class GenderTypeEnum {
  final int value;
  final String svgPath;
  final Color color;

  const GenderTypeEnum(this.value, this.svgPath, this.color);

  static const GenderTypeEnum Male = GenderTypeEnum(
      1, "assets/svg/male.svg", Colors.blue);
  static const GenderTypeEnum Female = GenderTypeEnum(
      0, "assets/svg/female.svg", Colors.pinkAccent);

  static GenderTypeEnum getGender(int value) {
    if (value == 0) {
      return Female;
    } else {
      return Male;
    }
  }
}
