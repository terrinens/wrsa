import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wrsa_app/utils/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrsa_app/widgets/alarm/alarm_picker_screen.dart';
import 'package:wrsa_app/models/alarm_data.dart';
import 'dart:convert';

class AlarmList extends StatefulWidget {
  const AlarmList({super.key});

  @override
  State<AlarmList> createState() => _AlarmListState();
}

class _AlarmListState extends State<AlarmList> {
  List<AlarmItem> alarms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  // 다음 알람 ID 생성 (1부터 시작, Int 범위 내)
  int _getNextAlarmId() {
    if (alarms.isEmpty) {
      return 1;
    }
    return alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // 저장된 알람 불러오기
  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('alarms');
    final alarmsJson = prefs.getStringList('alarms') ?? [];

    setState(() {
      alarms = alarmsJson
          .map((json) => AlarmItem.fromJson(jsonDecode(json)))
          .toList();
      isLoading = false;
    });

    // 활성화된 알람 재설정
    for (var alarm in alarms) {
      if (alarm.isEnabled) {
        await _scheduleAlarm(alarm);
      }
    }
  }

  // 알람 저장
  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = alarms
        .map((alarm) => jsonEncode(alarm.toJson()))
        .toList();
    await prefs.setStringList('alarms', alarmsJson);
  }

  // 알람 스케줄 설정
  Future<void> _scheduleAlarm(AlarmItem alarm) async {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    await AlarmManager.setAlarm(
      id: alarm.id,
      dateTime: alarmTime,
      title: alarm.title,
    );
  }

  Future<void> _addAlarm() async {
    // 페이지 이동 방식으로 변경
    final AlarmData? alarmData = await Navigator.push<AlarmData>(
      context,
      MaterialPageRoute(builder: (context) => const AlarmTimePickerScreen()),
    );

    if (alarmData != null) {
      final newAlarm = AlarmItem(
        id: _getNextAlarmId(),
        title: alarmData.title,
        time: alarmData.time,
        isEnabled: false,
      );

      setState(() {
        alarms.add(newAlarm);
      });

      await _saveAlarms();
    }
  }

  void _removeAlarm(int id) async {
    setState(() {
      alarms.removeWhere((alarm) => alarm.id == id);
    });
    await AlarmManager.cancelAlarm(id);
    await _saveAlarms();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 알람 추가 버튼
        AlarmAddButton(addAlarm: _addAlarm),
        const Divider(height: 1),
        // 알람 리스트
        ...alarms.map(
          (alarm) => AlarmItemWidget(
            alarm: alarm,
            onDelete: () => _removeAlarm(alarm.id),
            onAlarmChanged: (alarmData) async {
              setState(() {
                alarm.time = alarmData.time;
                alarm.title = alarmData.title;
              });
              if (alarm.isEnabled) {
                await _scheduleAlarm(alarm);
              }
              await _saveAlarms();
            },
            onToggle: (value) async {
              if (value) {
                await _scheduleAlarm(alarm);
              } else {
                await AlarmManager.cancelAlarm(alarm.id);
              }

              setState(() {
                alarm.isEnabled = value;
              });
              await _saveAlarms();
            },
          ),
        ),
      ],
    );
  }
}

/// 알람을 추가 할 수 있는 버튼입니다.
class AlarmAddButton extends StatelessWidget {
  final VoidCallback addAlarm;

  const AlarmAddButton({super.key, required this.addAlarm});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: addAlarm,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, weight: 20),
              ),
              const SizedBox(width: 16),
              const Text(
                '알람 추가',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlarmItem {
  final int id;
  String title;
  TimeOfDay time;
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
}

class AlarmItemWidget extends StatelessWidget {
  final AlarmItem alarm;
  final VoidCallback onDelete;
  final Function(AlarmData) onAlarmChanged;
  final Function(bool) onToggle;

  const AlarmItemWidget({
    super.key,
    required this.alarm,
    required this.onDelete,
    required this.onAlarmChanged,
    required this.onToggle,
  });

  Future<void> _selectTime(BuildContext context) async {
    // 페이지 이동 방식으로 변경 - AlarmData 받기
    final AlarmData? alarmData = await Navigator.push<AlarmData>(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmTimePickerScreen(
          initialTime: alarm.time,
          initialTitle: alarm.title,
        ),
      ),
    );

    if (alarmData != null) {
      onAlarmChanged(alarmData);
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alarm.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.alarm,
                size: 32,
                color: alarm.isEnabled ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(alarm.time),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alarm.isEnabled ? '알람 설정됨' : '알람 꺼짐',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              Switch(value: alarm.isEnabled, onChanged: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}
