import 'package:flutter/material.dart';
import 'package:wrsa_app/widgets/forecast.dart';
import 'package:wrsa_app/widgets/hourly.dart';
import 'package:wrsa_app/widgets/location.dart';
import 'package:wrsa_app/widgets/temper.dart';
import 'package:wrsa_app/widgets/weather.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LocationDateRow(location: 'test1', syncTime: 'test1',),
                SizedBox(height: 40),
                MainTemperatureDisplay(cloud: 'test2', temper: 22,),
                SizedBox(height: 30),
                WeatherDetailsGrid(),
                SizedBox(height: 30),
                HourlyForecastCard(),
                SizedBox(height: 30),
                WeeklyForecastCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


