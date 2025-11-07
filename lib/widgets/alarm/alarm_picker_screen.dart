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

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialTime != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? '알람 시간 수정' : '알람 추가')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 시간 선택
                  SizedBox(
                    width: 120,
                    height: 300,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 60,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: selectedHour,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedHour = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 24,
                        builder: (context, index) {
                          final isSelected = selectedHour == index;
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 48 : 32,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.black54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  // 분 선택
                  SizedBox(
                    width: 120,
                    height: 300,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 60,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: selectedMinute,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedMinute = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60,
                        builder: (context, index) {
                          final isSelected = selectedMinute == index;
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 48 : 32,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.black54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 저장, 취소 버튼
          SaveCancelButton(
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

class SaveCancelButton extends StatelessWidget {
  final int hour;
  final int minute;

  final ValueChanged<TimeOfDay> onSave;
  final VoidCallback onCancel;

  const SaveCancelButton({
    super.key,
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
