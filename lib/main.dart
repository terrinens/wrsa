import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:wrsa_app/models/res_data.dart';
import 'package:wrsa_app/services/weather.kts.dart';
import 'package:wrsa_app/theme/colors.dart' as custom_colors;
import 'package:wrsa_app/utils/alarm.dart';
import 'package:wrsa_app/utils/app_permission.dart';
import 'package:wrsa_app/utils/areaGrid.dart';
import 'package:wrsa_app/utils/background/data_sync.dart';
import 'package:wrsa_app/widgets/alarm/alarm_list.dart';
import 'package:wrsa_app/widgets/alarm/alarm_ring_screen.dart';
import 'package:wrsa_app/widgets/weather/location.dart';
import 'package:wrsa_app/widgets/weather/temper.dart';
import 'package:wrsa_app/widgets/weather/weather.dart';

import 'constants/cloud.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late final DataSyncManager dataManger;

late final Logger log;

void main() async {
  logInit();
  WidgetsFlutterBinding.ensureInitialized();
  await AppPermission.initialize();

  try {
    await AlarmManager.initialize();
    log.info('알람 매니저 초기화 완료');
  } catch (e) {
    log.warning('알람 매니저 초기화 오류 발생 : $e');
  }

  // TODO 위치를 변경할수 있게 설계할것
  final grid = getAreaCodeFromGrid(60, 127);
  dataManger = DataSyncManager(grid: grid, scheduleHour: 4, scheduleMinute: 0);
  await dataManger.init();

  final today = DateFormat('yyyyMMdd').format(DateTime.now());
  var data = await dataManger.getData(today, grid);

  if (data == null) {
    log.info('초기 데이터 존재하지 않음. 동기화 시도');
    await dataManger.manualSync();

    data = await dataManger.getData(today, grid);
    if (data != null) {
      log.info('동기화 완료. 데이터 로드 성공: ${data.fcstDate}');
    } else {
      log.warning('동기화 했지만 데이터를 찾을 수 없음');
    }
  }

  await AlarmManager.initialize();

  // 백그라운드에서도 작동하는 알람 리스너
  Alarm.ringStream.stream.listen((settings) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AlarmRingScreen(alarmSettings: settings),
      ),
    );
  });

  runApp(const WeatherApp());
}

void logInit() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('[${record.level.name}] ${record.loggerName}: ${record.message}');
    }
  });

  log = Logger('wrsa main');
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // GlobalKey 연결
      debugShowCheckedModeBanner: false,
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late Future<ResData> _weatherDataFuture;

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = _loadWeatherData();
  }

  Future<ResData> _loadWeatherData() async {
    final grid = getAreaCodeFromGrid(60, 127);
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    return await dataManger.getData(today, grid) ?? getDummy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: custom_colors.backgroundWhite,
      body: FutureBuilder<ResData>(
        future: _weatherDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('데이터 없음'));
          }

          final data = snapshot.data!;

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocationDateRow(location: data.name, syncTime: 'test1'),
                    SizedBox(height: 40),
                    MainTemperatureDisplay(
                      sky: Sky.fromValue(data.sky),
                      temper: data.avgTempera,
                    ),
                    SizedBox(height: 30),
                    WeatherDetailsGrid(wash: data.wash, wind: data.wind),
                    SizedBox(height: 30),
                    AlarmList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
