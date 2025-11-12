import 'package:alarm/alarm.dart';

// FUTURE 추후, 알람 커스텀에 사용할 옵션
String getAlarmSound() {
  return 'assets/audio/default.mp3';
}

class AlarmManager {
  static Future<void> initialize() async {
    await Alarm.init();
  }

  static Future<void> setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: getAlarmSound(),
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        fadeDuration: Duration(seconds: 5),
        volume: 0.8,
      ),
      notificationSettings: NotificationSettings(title: title, body: ''),
      androidStopAlarmOnTermination: false,
      // TEST 앱이 종료되어도 알람 울림 ??
      warningNotificationOnKill: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
  }

  static Future<void> cancelAllAlarms() async {
    // 모든 알람 ID 가져오기
    final alarms = await Alarm.getAlarms();
    for (var alarm in alarms) {
      await Alarm.stop(alarm.id);
    }
  }

  static Future<List<AlarmSettings>> getAllAlarms() {
    return Alarm.getAlarms();
  }

  static Future<bool> isRinging(int id) async {
    var alarms = await Alarm.getAlarms();
    return alarms.any((alarm) => alarm.id == id);
  }

  static AlarmSettings copyWith(
    AlarmSettings setting,
    DateTime dateTime,
    String title,
    String body,
  ) {
    return AlarmSettings(
      id: setting.id,
      dateTime: dateTime,
      assetAudioPath: setting.assetAudioPath,
      loopAudio: setting.loopAudio,
      vibrate: setting.vibrate,
      androidFullScreenIntent: setting.androidFullScreenIntent,
      volumeSettings: setting.volumeSettings,
      notificationSettings: NotificationSettings(
        title: setting.notificationSettings.title,
        body: body,
      ),
      androidStopAlarmOnTermination: setting.androidStopAlarmOnTermination,
      warningNotificationOnKill: setting.warningNotificationOnKill,
    );
  }
}
