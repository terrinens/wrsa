import 'package:flutter/material.dart';

// 주간 예보 카드 위젯
class WeeklyForecastCard extends StatelessWidget {
  const WeeklyForecastCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          WeeklyForecastHeader(),
          SizedBox(height: 20),
          DailyForecastItem(
            day: 'Today',
            condition: 'Rain',
            tempRange: '9°/8°',
          ),
        ],
      ),
    );
  }
}

// 주간 예보 헤더 위젯
class WeeklyForecastHeader extends StatelessWidget {
  const WeeklyForecastHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.calendar_today, size: 20),
            SizedBox(width: 10),
            Text(
              '7-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          'more details ▶',
          style: TextStyle(
            color: Colors.blue[300],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// 일별 예보 항목 위젯
class DailyForecastItem extends StatelessWidget {
  final String day;
  final String condition;
  final String tempRange;

  const DailyForecastItem({
    super.key,
    required this.day,
    required this.condition,
    required this.tempRange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.water_drop,
              color: Colors.blue[300],
              size: 20,
            ),
            const SizedBox(width: 5),
            Text(
              condition,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Text(
          tempRange,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}