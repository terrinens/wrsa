import 'package:flutter/material.dart' hide VerticalDivider;
import 'package:wrsa_app/widgets/divider.dart';
import 'package:wrsa_app/constants/cloud.dart';

// 날씨 아이콘 위젯
class WeatherIcon extends StatelessWidget {
  final Sky sky;

  const WeatherIcon({super.key, required this.sky});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
      child: Icon(sky.toIcon().icon, size: 80),
    );
  }
}

// 날씨 상세 정보 그리드 위젯
class WeatherDetailsGrid extends StatelessWidget {
  final String wash;
  final double wind;

  const WeatherDetailsGrid({super.key, required this.wash, required this.wind});

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.blue[300] ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: WeatherDetailItem(
                  icon: Icons.dry_cleaning,
                  label: '빨래',
                  value: wash,
                  iconColor: iconColor,
                ),
              ),

              const VerticalDivider(),
              Expanded(
                child: WeatherDetailItem(
                  icon: Icons.wind_power_outlined,
                  label: '평균 풍속',
                  value: wind,
                  iconColor: iconColor,
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: WeatherDetailItem(
                  icon: Icons.warning,
                  label: '개발중',
                  value: '개발중',
                  iconColor: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 날씨 상세 항목 위젯
class WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic value;
  final Color iconColor;

  const WeatherDetailItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: iconColor.withValues(alpha: 0.2),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
