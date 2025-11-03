import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'dart:io';

import 'package:wrsa_app/models/res_data.dart';

final log = Logger('weather api');
const apiUrl = "https://weather-api-server-3spkai4ruq-dt.a.run.app";

Future<List<ResData>> getData(int nx, int ny) async {
  try {
    var url = Uri.parse('$apiUrl?nx=$nx&ny=$ny');
    var response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != HttpStatus.ok) {
      log.info('사용자의 잘못된 요청 감지');
      return getDummy();
    }

    final resBody = response.body;
    final List<dynamic> jsonArray = convert.jsonDecode(resBody);

    return jsonArray
        .map((e) => ResData.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    log.warning('Error fetching weather data: $e');
    return List.of(getDummy());
  }
}

getDummy() {
  return ResData(
    name: 'notfound',
    fcstDate: "20251103",
    avgTempera: 0,
    wash: "notfound",
    sky: 0,
    wind: 0,
  );
}
