import 'package:flutter/material.dart';

/// 알람 추가/수정 화면에서 반환되는 데이터
class AlarmData {
  final TimeOfDay time;
  final String title;

  AlarmData({
    required this.time,
    required this.title,
  });
}
