import 'package:logging/logging.dart';
import 'package:wrsa_app/services/weather.kts.dart' as weather;
import 'package:wrsa_app/main.dart';

import '../lib/utils/log.dart';

var log = Logger("unit debug");

void main() async {
  logSet();
  var value = await weather.getData(69, 107);
  for (var o in value) {
    log.info('Name: ${o.name}');
    log.info('Forecast Date: ${o.fcstDate}');
    log.info('Average Temperature: ${o.avgTempera}');
    log.info('Wash: ${o.wash}');
    log.info('Sky: ${o.sky}');
    log.info('Wind: ${o.wind}\n\n');
  }
}
