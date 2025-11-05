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
        decoration: BoxDecoration(
            color: Colors.blue[50], shape: BoxShape.circle),
        child: Icon(sky.toIcon().icon, size: 80)
    );
  }
}

// 날씨 상세 정보 그리드 위젯
class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key});

  @override
  Widget build(BuildContext context) {
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
                  icon: Icons.thermostat,
                  label: '빨래',
                  value: '비추천',
                  iconColor: Colors.blue[300]!,
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: WeatherDetailItem(
                  icon: Icons.water_drop,
                  label: 'Precipitation',
                  value: '100%',
                  iconColor: Colors.blue[300]!,
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: WeatherDetailItem(
                  icon: Icons.wb_sunny,
                  label: 'UV Index',
                  value: 'Low',
                  iconColor: Colors.blue[300]!,
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
  final String value;
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
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
