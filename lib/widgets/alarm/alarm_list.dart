import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wrsa_app/models/alarm_data.dart';
import 'package:wrsa_app/models/alarm_item.dart';
import 'package:wrsa_app/utils/alarm.dart';
import 'package:wrsa_app/widgets/alarm/alarm_picker_screen.dart';

class AlarmList extends StatefulWidget {
  final AlarmManager alarmManager;

  const AlarmList({super.key, required this.alarmManager});

  @override
  State<AlarmList> createState() => _AlarmListState();
}

class _AlarmListState extends State<AlarmList> with WidgetsBindingObserver {
  late Set<AlarmItem> alarms;
  bool isLoading = true;
  late AlarmManager alarmManager;

  @override
  void initState() {
    super.initState();
    alarmManager = widget.alarmManager;
    _loadAlarms();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAlarms();
    }
  }

  /// 알람 매니저의 정보를 갱신하고, 갱신된 정보를 [alarms]에 할당하여 사용 할 수 있도록 합니다.
  Future<void> _loadAlarms() async {
    await alarmManager.loadAlarmsInfo();

    setState(() {
      alarms = alarmManager.alarms;
      isLoading = false;
    });
  }

  /// '새'알람을 등록을 하기 위해 전용 페이지로 이동하고, 알람을 등록합니다.
  Future<void> _addAlarm() async {
    final AlarmData? alarmData = await Navigator.push<AlarmData>(
      context,
      MaterialPageRoute(builder: (context) => const AlarmTimePickerScreen()),
    );

    if (alarmData != null) {
      final newAlarm = AlarmItem(
        id: alarmManager.getNextAlarmId(),
        title: alarmData.title,
        time: alarmData.time,
        isEnabled: false,
      );

      await alarmManager.setScheduleAlarm(newAlarm);
    }
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
            onDelete: () => alarmManager.removeAlarm(alarm.id),
            onAlarmChanged: (alarmData) async {
              setState(() {
                alarm.time = alarmData.time;
                alarm.title = alarmData.title;
              });

              if (alarm.isEnabled) {
                await alarmManager.setScheduleAlarm(alarm);
              }
            },
            onToggle: (value) async {
              if (value) {
                await alarmManager.enableAlarm(alarm.id);
              } else {
                await alarmManager.cancelAlarm(alarm.id);
              }

              setState(() {
                alarm.isEnabled = value;
              });
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
