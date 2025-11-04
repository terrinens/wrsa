import 'package:json_annotation/json_annotation.dart';

part 'res_data.g.dart';

@JsonSerializable()
class ResData {
  @JsonKey(name: 'Name')
  final String name;
  @JsonKey(name: 'FcstDate')
  final String fcstDate;
  @JsonKey(name: 'AvgTempera')
  final double avgTempera;
  @JsonKey(name: 'Wash')
  final String wash;
  @JsonKey(name: 'Sky')
  final int sky;
  @JsonKey(name: 'Wind')
  final double wind;

  ResData({
    required this.name,
    required this.fcstDate,
    required this.avgTempera,
    required this.wash,
    required this.sky,
    required this.wind,
  });

  factory ResData.fromJson(Map<String, dynamic> json) =>
      _$ResDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$ResDataToJson(this);
}
