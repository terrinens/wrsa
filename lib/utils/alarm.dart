import 'package:alarm/alarm.dart';

class AlarmManager {
  static Future<void> initialize() async {
    await Alarm.init();
  }

  // FUTURE 추후, 알람 커스텀에 사용할 옵션
  static String _getAlarmSound() {
    return 'assets/audio/default.mp3';
  }

  static Future<void> setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: _getAlarmSound(),
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: title,
      notificationBody: body,
      enableNotificationOnKill: true,
      // 앱이 종료되어도 알람 울림
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
  }

  static Future<void> cancelAllAlarms() async {
    // 모든 알람 ID 가져오기
    final alarms = Alarm.getAlarms();
    for (var alarm in alarms) {
      await Alarm.stop(alarm.id);
    }
  }

  static List<AlarmSettings> getAllAlarms() {
    return Alarm.getAlarms();
  }

  static bool isRinging(int id) {
    return Alarm.getAlarms().any((alarm) => alarm.id == id);
  }
}
