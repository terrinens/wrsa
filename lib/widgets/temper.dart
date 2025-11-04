
import 'package:flutter/material.dart';
import 'package:wrsa_app/widgets/weather.dart';

// 온도 단위 토글 위젯
class TemperatureToggle extends StatelessWidget {
  const TemperatureToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              '°C',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Text(
              '°F',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 메인 온도 표시 위젯
class MainTemperatureDisplay extends StatelessWidget {
  final num temper;
  final String cloud;
  const MainTemperatureDisplay({super.key, required this.temper, required this.cloud});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TemperatureText(temper: temper, cloud: cloud,),
        WeatherIcon(),
      ],
    );
  }
}

// 온도 텍스트 위젯
class TemperatureText extends StatelessWidget {
  final num temper;
  final String cloud;

  const TemperatureText({super.key, required this.temper, required this.cloud});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$temper°C',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          cloud,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}