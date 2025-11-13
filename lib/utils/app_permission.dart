import 'dart:io';

import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  static Logger log = Logger('WRSA Permission Manger');

  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      log.info('안드로이드 환경 감지. 안드로이드 권한 요청 시도');
      await _android();
    }
  }

  static Future<void> _android() async {
    // 1. 알림 권한
    if (await Permission.notification.isDenied) {
      try {
        log.info('유저에게 알림 권한 요청');
        await Permission.notification.request();
      } catch (e) {
        log.warning('알림 권한 요청 실패 $e');
      }
    }

    // 2. 정확한 알람 권한 (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      try {
        log.info('유저에게 정확한 알람 권한 요청');
        await Permission.scheduleExactAlarm.request();
      } catch (e) {
        log.warning('정확한 알람 권한 요청 실패 $e');
      }
    }

    // 3. 다른 앱 위에 표시 권한
    if (await Permission.systemAlertWindow.isDenied) {
      try {
        log.info('유저에게 다른 앱 위에 표시 권한 요청');
        await Permission.systemAlertWindow.request();
      } catch (e) {
        log.warning('다른 앱 위에 표시 권한 요청 실패 $e');
        await openAppSettings();
      }
    }

    // 4. 백그라운드 스케쥴링 권한 (배터리 최적화 무시)
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      try {
        log.info('유저에게 백그라운드 스케쥴링 권한 (배터리 최적화 무시) 요청');
        await Permission.ignoreBatteryOptimizations.request();
      } catch (e) {
        log.warning('백그라운드 스케쥴링 권한 요청 실패 $e');
      }
    }
  }
}
