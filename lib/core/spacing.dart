import 'package:flutter/material.dart';

SizedBox vSpace(double height) => SizedBox(height: height);
SizedBox hSpace(double width) => SizedBox(width: width);
Divider dSpace() => const Divider(color: Colors.grey, thickness: 0.3);

class Spacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}
