import 'package:flutter/material.dart';
import 'package:wrsa_app/models/res_data.dart';
import 'package:wrsa_app/utils/alarm.dart';
import 'package:wrsa_app/utils/areaGrid.dart';
import 'package:wrsa_app/utils/data_sync.dart';
import 'package:wrsa_app/widgets/alarm/alarm_list.dart';
import 'package:wrsa_app/widgets/alarm/alarm_ring_screen.dart';
import 'package:wrsa_app/theme/colors.dart' as custom_colors;
import 'package:alarm/alarm.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmManager.initialize();

  // 백그라운드에서도 작동하는 알람 리스너
  Alarm.ringStream.stream.listen((settings) {
    log.info('알람 작동 : ${settings.id}');
    
    // 전역 네비게이터를 사용해서 화면 이동
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AlarmRingScreen(alarmSettings: settings),
      ),
    );
  });

  runApp(const WeatherApp());
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

class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  Future<ResData> loadWeatherData() async {
    final grid = getAreaCodeFromGrid(60, 127);
    final date = '20251107';
    return await getData(date, grid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: custom_colors.backgroundWhite,
      body: FutureBuilder<ResData>(
        future: loadWeatherData(),
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
                    /*LocationDateRow(location: data.name, syncTime: 'test1'),
                    SizedBox(height: 40),
                    MainTemperatureDisplay(
                      sky: Sky.fromValue(data.sky),
                      temper: data.avgTempera,
                    ),
                    SizedBox(height: 30),
                    WeatherDetailsGrid(wash: data.wash, wind: data.wind),
                    SizedBox(height: 30),*/
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
