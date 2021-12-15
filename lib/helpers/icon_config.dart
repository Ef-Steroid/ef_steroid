import 'package:flutter/material.dart';

class IconConfig {
  final double? size;
  final Color? color;
  final IconData? iconData;

  const IconConfig({
    this.size,
    this.color,
    this.iconData,
  });

  /// The arguments provided will be used as fallback.
  Icon toIcon({
    Color? color,
    double? size,
  }) =>
      Icon(
        iconData,
        color: color ?? this.color,
        size: size ?? this.size,
      );
}
