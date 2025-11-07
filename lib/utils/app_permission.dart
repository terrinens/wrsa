import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await _android();
    }
  }

  static Future<void> _android() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 2. 정확한 알람 권한 (Android 12+)
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    if (!alarmStatus.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }

    // 3. 다른 앱 위에 표시 권한
    if (await Permission.systemAlertWindow.isDenied) {
      final status = await Permission.systemAlertWindow.request();
      if (status.isDenied) {
        await openAppSettings();
      }
    }
  }
}
