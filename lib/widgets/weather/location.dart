import 'package:flutter/material.dart';
import 'package:wrsa_app/widgets/weather/temper.dart';

// 위치와 날짜 표시 위젯
class LocationDateRow extends StatelessWidget {
  final String location;
  final String syncTime;

  const LocationDateRow({
    super.key,
    required this.location,
    required this.syncTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LocationInfo(location: location, syncTime: syncTime),
        const TemperatureToggle(),
      ],
    );
  }
}

// 위치 정보 위젯
class LocationInfo extends StatelessWidget {
  final String location;
  final String syncTime;

  const LocationInfo({
    super.key,
    required this.location,
    required this.syncTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          location,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(syncTime, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
