import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:wrsa_app/utils/alarm.dart';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 알람 아이콘
              Icon(Icons.alarm, size: 120, color: Colors.white),
              const SizedBox(height: 40),

              // 시간 표시
              Text(
                '${alarmSettings.dateTime.hour.toString().padLeft(2, '0')}:'
                '${alarmSettings.dateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 16),

              // 알람 제목
              Text(
                alarmSettings.notificationTitle,
                style: const TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const SizedBox(height: 8),

              // 알람 내용
              Text(
                alarmSettings.notificationBody,
                style: const TextStyle(fontSize: 16, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),

              // 알람 끄기 버튼
              ElevatedButton(
                onPressed: () async {
                  await Alarm.stop(alarmSettings.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  '알람 끄기',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // 다시 알림 버튼 (스누즈)
              TextButton(
                onPressed: () async {
                  // 5분 후 다시 알림
                  final snoozeTime = DateTime.now().add(
                    const Duration(minutes: 5),
                  );

                  await Alarm.stop(alarmSettings.id);

                  final snoozeSettings = AlarmSettings(
                    id: alarmSettings.id,
                    dateTime: snoozeTime,
                    loopAudio: alarmSettings.loopAudio,
                    vibrate: alarmSettings.vibrate,
                    notificationTitle: alarmSettings.notificationTitle,
                    notificationBody: '5분 후 다시 알림',
                    enableNotificationOnKill:
                        alarmSettings.enableNotificationOnKill,
                    assetAudioPath: getAlarmSound(),
                  );

                  await Alarm.set(alarmSettings: snoozeSettings);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('5분 후 다시 알림')));
                  }
                },
                child: const Text(
                  '5분 후 다시 알림',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
