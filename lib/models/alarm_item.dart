import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AlarmItem {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  String title;
  @JsonKey(name: 'Name')
  TimeOfDay time;
  @JsonKey(name: 'Name')
  bool isEnabled;

  AlarmItem({
    required this.id,
    required this.title,
    required this.time,
    required this.isEnabled,
  });

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'isEnabled': isEnabled,
    };
  }

  // JSON에서 생성
  factory AlarmItem.fromJson(Map<String, dynamic> json) {
    return AlarmItem(
      id: json['id'],
      title: json['title'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      isEnabled: json['isEnabled'],
    );
  }

  static AlarmItem toAlarmItem({
    required AlarmSettings alarmSettings,
    String? title,
    DateTime? dateTime,
    bool enabled = false,
  }) {
    final timeOfDay = TimeOfDay(
      hour: dateTime?.hour ?? alarmSettings.dateTime.hour,
      minute: dateTime?.minute ?? alarmSettings.dateTime.minute,
    );
    return AlarmItem(
      id: alarmSettings.id,
      title: title ?? alarmSettings.notificationSettings.title,
      time: timeOfDay,
      isEnabled: enabled,
    );
  }
}
