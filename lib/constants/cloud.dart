import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wrsa_app/theme/colors.dart' as c_colors;

enum Sky {
  sunny(1), // 맑음
  mostly(3), // 구름 많음
  blur(4); // 흐림

  final int value;

  const Sky(this.value);

  @override
  String toString() {
    switch (this) {
      case Sky.sunny:
        return '맑음';
      case Sky.mostly:
        return '구름 많음';
      case Sky.blur:
        return '흐림';
    }
  }

  Icon toIcon() {
    switch (this) {
      case Sky.sunny:
        return Icon(CupertinoIcons.sun_max);
      case Sky.mostly:
        return Icon(Icons.cloud_queue,  color: c_colors.primaryBlue);
      case Sky.blur:
        return const Icon(Icons.cloud);
    }
  }

  static Sky fromValue(int value) {
    return Sky.values.firstWhere(
      (sky) => sky.value == value,
      orElse: () => Sky.sunny,
    );
  }
}
