// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastHistoryModel _$ForecastHistoryModelFromJson(
  Map<String, dynamic> json,
) => ForecastHistoryModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => ForecastHistoryData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ForecastHistoryModelToJson(
  ForecastHistoryModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

ForecastHistoryData _$ForecastHistoryDataFromJson(Map<String, dynamic> json) =>
    ForecastHistoryData(
      date: json['date'] as String?,
      day: json['day'] as String?,
      forecast: json['forecast'] == null
          ? null
          : ForecastHistoryForecast.fromJson(
              json['forecast'] as Map<String, dynamic>,
            ),
      reflection: json['reflection'] == null
          ? null
          : Reflection.fromJson(json['reflection'] as Map<String, dynamic>),
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => ForecastActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyNotes: json['dailyNotes'],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$ForecastHistoryDataToJson(
  ForecastHistoryData instance,
) => <String, dynamic>{
  'date': instance.date,
  'day': instance.day,
  'forecast': instance.forecast?.toJson(),
  'reflection': instance.reflection?.toJson(),
  'activities': instance.activities?.map((e) => e.toJson()).toList(),
  'dailyNotes': instance.dailyNotes,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

ForecastHistoryForecast _$ForecastHistoryForecastFromJson(
  Map<String, dynamic> json,
) => ForecastHistoryForecast(
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  plan: json['plan'] as String?,
  notes: json['notes'] as String?,
  userNotes: (json['userNotes'] as List<dynamic>?)
      ?.map((e) => UserNote.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$ForecastHistoryForecastToJson(
  ForecastHistoryForecast instance,
) => <String, dynamic>{
  'emotions': instance.emotions?.map((e) => e.toJson()).toList(),
  'plan': instance.plan,
  'notes': instance.notes,
  'userNotes': instance.userNotes?.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt,
};

Emotion _$EmotionFromJson(Map<String, dynamic> json) => Emotion(
  key: json['key'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$EmotionToJson(Emotion instance) => <String, dynamic>{
  'key': instance.key,
  'intensity': instance.intensity,
  'imageUrl': instance.imageUrl,
  'title': instance.title,
};

UserNote _$UserNoteFromJson(Map<String, dynamic> json) => UserNote(
  content: json['content'] as String?,
  createdAt: json['createdAt'] as String?,
  isPrivate: json['isPrivate'] as bool?,
  isAspire: json['isAspire'] as bool?,
  likes: (json['likes'] as num?)?.toInt(),
  comments: (json['comments'] as num?)?.toInt(),
  id: json['_id'] as String?,
);

Map<String, dynamic> _$UserNoteToJson(UserNote instance) => <String, dynamic>{
  'content': instance.content,
  'createdAt': instance.createdAt,
  'isPrivate': instance.isPrivate,
  'isAspire': instance.isAspire,
  'likes': instance.likes,
  'comments': instance.comments,
  '_id': instance.id,
};

Reflection _$ReflectionFromJson(Map<String, dynamic> json) => Reflection(
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  wentAsForecast: json['wentAsForecast'] as bool?,
  compareToForecast: (json['compareToForecast'] as num?)?.toInt(),
  planUseful: json['planUseful'] as bool?,
  planFeedback: json['planFeedback'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$ReflectionToJson(Reflection instance) =>
    <String, dynamic>{
      'emotions': instance.emotions?.map((e) => e.toJson()).toList(),
      'wentAsForecast': instance.wentAsForecast,
      'compareToForecast': instance.compareToForecast,
      'planUseful': instance.planUseful,
      'planFeedback': instance.planFeedback,
      'createdAt': instance.createdAt,
    };

ForecastActivity _$ForecastActivityFromJson(Map<String, dynamic> json) =>
    ForecastActivity(
      name: json['name'] as String?,
      completed: json['completed'] as bool?,
    );

Map<String, dynamic> _$ForecastActivityToJson(ForecastActivity instance) =>
    <String, dynamic>{'name': instance.name, 'completed': instance.completed};
