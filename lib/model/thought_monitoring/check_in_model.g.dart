// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInModel _$CheckInModelFromJson(Map<String, dynamic> json) => CheckInModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CheckInData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CheckInModelToJson(CheckInModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

CheckInData _$CheckInDataFromJson(Map<String, dynamic> json) => CheckInData(
  id: json['id'] as String?,
  mood: json['mood'] as String?,
  day: json['day'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$CheckInDataToJson(CheckInData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mood': instance.mood,
      'day': instance.day,
      'createdAt': instance.createdAt,
    };
