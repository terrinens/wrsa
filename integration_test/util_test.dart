import 'package:flutter_test/flutter_test.dart';
import 'package:wrsa_app/utils/areaGrid.dart';
import 'package:wrsa_app/utils/data_sync.dart';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:wrsa_app/models/res_data.dart';

import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('data sync test', () {
    testWidgets('data local save test', (tester) async {
      await localSyncTest();
      log.info('데이터 로컬 저장 테스트 성공');
    });

    testWidgets('local del test', (tester) async {
      await delData('20251107');
      log.info('로컬 데이터 삭제 테스트 성공');
    });
  });
}

Future<void> localSyncTest() async {
  final file = File('integration_test/dummy/dummy.json');
  expect(await file.exists(), true, reason: 'dummy.json 파일 존재하지 않음');

  final jsonString = file.readAsStringSync();
  final List<dynamic> jsonData =
      convert.jsonDecode(jsonString) as List<dynamic>;

  final List<ResData> data = jsonData
      .map((item) => ResData.fromJson(item as Map<String, dynamic>))
      .toList();

  final grid = getAreaCodeFromGrid(60, 127);

  localSync(data, grid);
}
