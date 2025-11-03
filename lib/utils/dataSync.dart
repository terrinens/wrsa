import 'dart:io';
import 'dart:convert' as convert;

import 'package:path_provider/path_provider.dart';
import 'package:wrsa_app/models/res_data.dart';
import 'package:wrsa_app/services/weather.kts.dart';
import 'package:logging/logging.dart';

final log = Logger('data sync');
// TODO 백그라운드에서 데이터 갱신하는 로직 작성할것

/// 날씨 데이터의 고유한 디렉토리를 반환합니다.
Future<String> _savePath(String date) async {
  final dir = await getApplicationDocumentsDirectory();
  final localFile = File('${dir.path}/wData/');
  // TODO 사용자 설정이 확립되면 두번째 경로를 nxny로 바꿀것
  return '$localFile/2030/$date';
}

/// 고유한 디렉토리에 사용될 파일을 저장합니다.
void localSync(List<ResData> data) async {
  for (var o in data) {
    final fileName = await _savePath(o.fcstDate);
    final file = File(fileName);
    final jsonStr = convert.jsonEncode(o);
    await file.writeAsString(jsonStr);
  }
}

/// 고유한 디렉토리에서 data를 기반으로 파일을 가져오고, ResData 형태로 반환합니다.
Future<ResData> getData(String date) async {
  try {
    final filePath = await _savePath(date);
    final file = File(filePath);

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
