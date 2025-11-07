import 'package:flutter/material.dart';

class AlarmTimePickerScreen extends StatefulWidget {
  final TimeOfDay? initialTime;

  const AlarmTimePickerScreen({super.key, this.initialTime});

  @override
  State<AlarmTimePickerScreen> createState() => _AlarmTimePickerScreenState();
}

class _AlarmTimePickerScreenState extends State<AlarmTimePickerScreen> {
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime?.hour ?? 7;
    selectedMinute = widget.initialTime?.minute ?? 0;
  }

  // FIX 1. 현재 시간,분 스크롤할 경우에 상단의 일정영역의 색이 바뀜.
  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialTime != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? '알람 시간 수정' : '알람 추가')),
      body: Column(
        children: [
          // 시간선택
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimePickerWheel(
                    itemCount: 24,
                    initialItem: selectedHour,
                    selectedValue: selectedHour,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedHour = index;
                      });
                    },
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  // ✨ 분 선택기를 TimePickerWheel 위젯으로 호출 ✨
                  _TimePickerWheel(
                    itemCount: 60,
                    initialItem: selectedMinute,
                    selectedValue: selectedMinute,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMinute = index;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 저장, 취소 버튼
          _SaveCancelButton(
            hour: selectedHour,
            minute: selectedMinute,
            onSave: (TimeOfDay time) {
              Navigator.pop(context, time);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _TimePickerWheel extends StatelessWidget {
  final int itemCount;
  final int initialItem;
  final int selectedValue;
  final ValueChanged<int> onSelectedItemChanged;

  const _TimePickerWheel({
    super.key,
    required this.itemCount,
    required this.initialItem,
    required this.selectedValue,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 300,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 60,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: initialItem),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected = selectedValue == index;
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: isSelected ? 48 : 32,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black54,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SaveCancelButton extends StatelessWidget {
  final int hour;
  final int minute;

  final ValueChanged<TimeOfDay> onSave;
  final VoidCallback onCancel;

  const _SaveCancelButton({
    required this.hour,
    required this.minute,
    required this.onSave,
    required this.onCancel,
  });

  Widget _buildButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _buildButton(
            title: '취소',
            onPressed: () {
              onCancel();
            },
          ),
          const SizedBox(width: 16),
          _buildButton(
            title: '저장',
            onPressed: () {
              onSave(TimeOfDay(hour: hour, minute: minute));
            },
          ),
        ],
      ),
    );
  }
}
