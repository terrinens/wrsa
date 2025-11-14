import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrsa_app/models/alarm_item.dart';

// FUTURE 추후, 알람 커스텀에 사용할 옵션
String getAlarmSound() {
  return 'assets/audio/default.mp3';
}

class AlarmManager {
  late List<AlarmItem> alarms;
  static final Logger _log = Logger('AlarmManger');

  static Future<void> _setAlarm({
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
        volume: kDebugMode ? 0.1 : 0.8,
      ),
      notificationSettings: NotificationSettings(title: title, body: ''),
      androidStopAlarmOnTermination: false,
    );

    try {
      _log.info('알람 세팅 : ${alarmSettings.dateTime}');
      await Alarm.set(alarmSettings: alarmSettings);
    } catch(e) {
      _log.warning('알람 세팅중 오류 발생 ID : ${alarmSettings.id}');
      _log.warning(e);
    }
  }

  // 다음 알람 ID 생성 (1부터 시작, Int 범위 내)
  int getNextAlarmId() {
    if (alarms.isEmpty) {
      return 1;
    }
    return alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// 알람을 취소합니다.
  Future<void> cancelAlarm(int id) async {
    try {
      await Alarm.stop(id);
      _saveAlarmsInfo();
    } catch (e) {
      _log.info('알람 종료에 실패했습니다.');
    }
  }

  /// '모든' 알람을 취소합니다.
  Future<void> cancelAllAlarms() async {
    late int id;
    try {
      _log.info('모든 알람 취소.');
      for (final a in alarms) {
        id = a.id;
        await cancelAlarm(id);
      }
    } catch (e) {
      _log.warning('알람 취소중 오류 발생. 오류 발생 알람 ID : $id');
      _log.warning(e);
    }
  }

  /// 알람을 '삭제'합니다. 모든 정보에서 삭제됩니다.
  Future<void> removeAlarm(int id) async {
    try {
      cancelAlarm(id);
      alarms.removeWhere((alarm) => alarm.id == id);
      _saveAlarmsInfo();
    } catch (e) {
      _log.info('알람을 삭제하던 도중 실패했습니다. 실패 ID : $id');
    }
  }

  /// 알람 정보를 공유 환경에 설정하고, [alarms] 변수에 값을 할당합니다.
  /// 초기 설정시 반드시 로드해야합니다.
  Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('alarms');
    final alarmsJson = prefs.getStringList('alarms') ?? [];

    alarms = alarmsJson
        .map((json) => AlarmItem.fromJson(jsonDecode(json)))
        .toList();

    _log.info('저장된 알람 개수: ${alarmsJson.length}');
    for (var json in alarmsJson) {
      _log.info('저장된 알람: $json');
    }

    // 활성화된 알람 재설정
    /*if (alarms.isNotEmpty) {
      _log.info('알람 재설정');
      for (var alarm in alarms) {
        if (alarm.isEnabled) {
          await setScheduleAlarm(alarm);
        }
      }
    }*/
  }

  /// 알람 스케줄을 등록합니다. 성공시 [alarm] 변수에 값 등록 및 공유 환경을 재설정합니다.
  Future<void> setScheduleAlarm(AlarmItem alarm) async {
    _log.info('새 알람 등록 시도.');
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

    try {
      await _setAlarm(id: alarm.id, dateTime: alarmTime, title: alarm.title);
      _log.info('새 알람 등록 성공');
    } catch (e) {
      _log.warning('새 알람 스케쥴 등록중 오류 발생 $e');
    }

    try {
      _log.info('새 알람 정보 저장중');
      alarms.add(alarm);
      _saveAlarmsInfo();
      _log.info('새 알람 등록 성공');
    } catch (e) {
      _log.warning('새 알람 등록 실패. 설정된 알람 삭제 $e');
      cancelAlarm(alarm.id);
    }
  }

  /// 알람 정보를 공유 환경에서 사용 할 수 있도록 [alarms]에 있는 정보를 변환하고, 공유 환경에 설정합니다.
  Future<void> _saveAlarmsInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = alarms
        .map((alarm) => jsonEncode(alarm.toJson()))
        .toList();
    await prefs.setStringList('alarms', alarmsJson);
  }

  /// [id]를 활용해, 해당 알람이 동작하는지 확인합니다.
  static Future<bool> isRinging(int id) async {
    var alarms = await Alarm.getAlarms();
    return alarms.any((alarm) => alarm.id == id);
  }

  /// 알람 기본 설정을 복사하고, 특정 정보만 변경 합니다.
  static AlarmSettings copyWith({
    required AlarmSettings setting,
    DateTime? dateTime,
    String? title,
    String? body,
  }) {
    return AlarmSettings(
      id: setting.id,
      dateTime: dateTime ?? setting.dateTime,
      assetAudioPath: setting.assetAudioPath,
      loopAudio: setting.loopAudio,
      vibrate: setting.vibrate,
      androidFullScreenIntent: setting.androidFullScreenIntent,
      volumeSettings: setting.volumeSettings,
      notificationSettings: NotificationSettings(
        title: title ?? setting.notificationSettings.title,
        body: body ?? setting.notificationSettings.body,
      ),
      androidStopAlarmOnTermination: setting.androidStopAlarmOnTermination,
      warningNotificationOnKill: setting.warningNotificationOnKill,
    );
  }
}
