import 'package:flutter/material.dart';

// 24시간 예보 카드 위젯
class HourlyForecastCard extends StatelessWidget {
  const HourlyForecastCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HourlyForecastHeader(),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                HourlyForecastItem(
                  temp: '7.5°',
                  condition: 'Broken Clouds',
                  time: 'Now',
                  isNow: true,
                ),
                HourlyForecastItem(
                  temp: '7.7°',
                  condition: 'Broken Clouds',
                  time: '01:00 AM',
                  isNow: false,
                ),
                HourlyForecastItem(
                  temp: '7.8°',
                  condition: 'Broken Clouds',
                  time: '02:00 AM',
                  isNow: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 24시간 예보 헤더 위젯
class HourlyForecastHeader extends StatelessWidget {
  const HourlyForecastHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.access_time, size: 20),
        SizedBox(width: 10),
        Text(
          '24-Hour Forecast',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// 시간별 예보 항목 위젯
class HourlyForecastItem extends StatelessWidget {
  final String temp;
  final String condition;
  final String time;
  final bool isNow;

  const HourlyForecastItem({
    super.key,
    required this.temp,
    required this.condition,
    required this.time,
    required this.isNow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          temp,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (isNow)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(height: 10),
        Icon(Icons.cloud, size: 40, color: Colors.blue[200]),
        const SizedBox(height: 10),
        Text(
          condition,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
