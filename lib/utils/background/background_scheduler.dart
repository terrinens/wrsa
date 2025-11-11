import 'package:logging/logging.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:wrsa_app/utils/background/data_sync.dart';

final Logger log = Logger('BackgroundScheduler');

class BackgroundScheduler {
  static const int _alarmId = 1;

  @pragma('vm:entry-point')
  static Future<void> backgroundCallback() async {
    await DataSyncManager.backgroundSync();
  }

  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    log.info('AndroidAlarmManager 초기화 완료');
  }

  Future<void> scheduleDaily({required int hour, required int minute}) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final success = await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      _alarmId,
      backgroundCallback,
      startAt: scheduledTime,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    if (success) {
      log.info(
        '매일 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}에 작업 예약 완료',
      );
    }
  }

  Future<void> cancelTask() async {
    await AndroidAlarmManager.cancel(_alarmId);
    log.info('예약된 작업 취소');
  }
}
