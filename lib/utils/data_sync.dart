import 'dart:io';
import 'dart:convert' as convert;

import 'package:path_provider/path_provider.dart';
import 'package:wrsa_app/models/res_data.dart';
import 'package:wrsa_app/services/weather.kts.dart';
import 'package:logging/logging.dart';
import 'package:wrsa_app/utils/areaGrid.dart';
import 'package:path/path.dart' as p;

final log = Logger('data sync');
// TODO 백그라운드에서 데이터 갱신하는 로직 작성할것

Future<Directory> _uqPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return Directory(p.absolute(dir.path, 'wData'));
}

/// 날씨 데이터의 [areaCode]의 고유한 디렉토리를 반환합니다.
Future<Directory> _savePath(String areaCode) async {
  final baseDir = await _uqPath();
  final absPath = p.absolute(baseDir.path, areaCode);
  final dir = Directory(absPath);

  await dir.create(recursive: true);

  return dir;
}

/// 고유한 디렉토리에 사용될 파일을 저장합니다. ex:ud-areaCode-date
void localSync(List<ResData> data, RepresentativeGrid grid) async {
  for (var o in data) {
    final dir = await _savePath(grid.areaCode);
    final file = File(p.absolute(dir.path, o.fcstDate));
    final jsonStr = convert.jsonEncode(o);
    await file.writeAsString(jsonStr);
  }
}

/// 고유한 디렉토리에서 data를 기반으로 파일을 가져오고, ResData 형태로 반환합니다.
Future<ResData> getData(String date, RepresentativeGrid grid) async {
  try {
    final dir = await _savePath(grid.areaCode);
    final file = File(p.absolute(dir.path, date));

    if (await file.exists()) {
      final contents = await file.readAsString();
      final json = convert.jsonDecode(contents);
      return ResData.fromJson(json);
    }

    return getDummy();
  } catch (e) {
    log.warning('Error reading local data: $e');
    return getDummy();
  }
}

/// date를 기준으로 고유한 디렉토리에 있는 파일들을 순회하여 date 미만의 파일들을 삭제합니다.
Future<void> delData(String date) async {
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

    log.info('old data clean complete');
  } catch (e) {
    log.warning('Error deleting old data: $e');
  }
}
