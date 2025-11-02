// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'res_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResData _$ResDataFromJson(Map<String, dynamic> json) => ResData(
  name: json['Name'] as String,
  fcstDate: json['FcstDate'] as String,
  avgTempera: (json['AvgTempera'] as num).toDouble(),
  wash: json['Wash'] as String,
  sky: (json['Sky'] as num).toInt(),
  wind: (json['Wind'] as num).toDouble(),
);

Map<String, dynamic> _$ResDataToJson(ResData instance) => <String, dynamic>{
  'Name': instance.name,
  'FcstDate': instance.fcstDate,
  'AvgTempera': instance.avgTempera,
  'Wash': instance.wash,
  'Sky': instance.sky,
  'Wind': instance.wind,
};
