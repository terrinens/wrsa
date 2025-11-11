import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrsa_app/models/res_data.dart';
import 'package:wrsa_app/services/weather.kts.dart' as wa;
import 'package:wrsa_app/utils/areaGrid.dart';
import 'package:wrsa_app/utils/background/background_scheduler.dart';

final log = Logger('data sync');

class DataSyncManager {
  final RepresentativeGrid grid;
  final int scheduleHour;
  final int scheduleMinute;

  static final dateFormat = DateFormat('yyyyMMdd');
  static const String _keyNx = 'grid_nx';
  static const String _keyNy = 'grid_ny';

  DataSyncManager({
    required this.grid,
    this.scheduleHour = 4,
    this.scheduleMinute = 0,
  });

  @pragma('vm:entry-point')
  static Future<void> backgroundSync() async {
    try {
      log.info('백그라운드 동기화 시작');

      final prefs = await SharedPreferences.getInstance();
      final nx = prefs.getInt(_keyNx) ?? 60;
      final ny = prefs.getInt(_keyNy) ?? 127;
      final grid = getAreaCodeFromGrid(nx, ny);

      final data = await wa.getData(grid);

      await _localSync(data, grid);

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await _delData(dateFormat.format(yesterday));

      log.info('백그라운드 동기화 완료');
    } catch (e, stackTrace) {
      log.severe('백그라운드 동기화 실패', e, stackTrace);
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNx, grid.nx);
    await prefs.setInt(_keyNy, grid.ny);

    await BackgroundScheduler.initialize();
    final scheduler = BackgroundScheduler();
    await scheduler.scheduleDaily(hour: scheduleHour, minute: scheduleMinute);

    log.info(
      '날씨 데이터 동기화 스케쥴러가 매일 ${scheduleHour.toString().padLeft(2, '0')}:${scheduleMinute.toString().padLeft(2, '0')}에 실행되도록 등록됐습니다.',
    );
  }

  /// 수동으로 동기화합니다.
  Future<void> manualSync() async {
    var data = await wa.getData(grid);
    await _localSync(data, grid);
  }

  static Future<Directory> _uqPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory(p.absolute(dir.path, 'wData'));
  }

  /// 날씨 데이터의 [areaCode]의 고유한 디렉토리를 반환합니다.
  static Future<Directory> _savePath(String areaCode) async {
    final baseDir = await _uqPath();
    final absPath = p.absolute(baseDir.path, areaCode);
    final dir = Directory(absPath);

    await dir.create(recursive: true);

    return dir;
  }

  /// 고유한 디렉토리에 사용될 파일을 저장합니다. ex:ud-areaCode-date
  static Future<void> _localSync(
    List<ResData> data,
    RepresentativeGrid grid,
  ) async {
    for (var o in data) {
      final dir = await _savePath(grid.areaCode);
      final file = File(p.absolute(dir.path, o.fcstDate));
      final jsonStr = convert.jsonEncode(o);
      await file.writeAsString(jsonStr);
    }
  }

  /// 고유한 디렉토리에서 data를 기반으로 파일을 가져오고, ResData 형태로 반환합니다.
  Future<ResData?> getData(String date, RepresentativeGrid grid) async {
    try {
      final dir = await _savePath(grid.areaCode);
      final file = File(p.absolute(dir.path, date));

      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = convert.jsonDecode(contents);
        return ResData.fromJson(json);
      }

      return null;
    } catch (e) {
      log.warning('로컬 데이터를 읽는데 실패했습니다. : $e');
      return null;
    }
  }

  /// date를 기준으로 고유한 디렉토리에 있는 파일들을 순회하여 date 미만의 파일들을 삭제합니다.
  static Future<void> _delData(String date) async {
    try {
      final baseDir = await _uqPath();
      if (!await baseDir.exists()) return;
      final currentContext = p.context;

      await for (final entity in baseDir.list(recursive: true)) {
        if (entity is File) {
          final fileName = entity.path.split(currentContext.separator).last;
          if (fileName.compareTo(date) < 0) {
            await entity.delete();
          }
        }
      }

      log.info('지정된 $date 이전 파일 삭제 완료');
    } catch (e) {
      log.warning('파일을 삭제하는 도중 오류가 발생했습니다 : $e');
    }
  }
}
