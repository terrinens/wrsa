import 'package:logging/logging.dart';
import 'package:wrsa_app/main.dart';
import 'package:wrsa_app/services/weather.kts.dart' as weather;
import 'package:wrsa_app/utils/background/data_sync.dart';
import 'package:wrsa_app/utils/log.dart';

var log = Logger("unit debug");

void main() async {
  final dataManger = DataSyncManager(cronExpression: "0 4 * * *", grid: grid);
  await dataManger.init();
}
