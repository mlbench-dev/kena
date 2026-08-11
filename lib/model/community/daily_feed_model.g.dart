// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyFeedModel _$DailyFeedModelFromJson(Map<String, dynamic> json) =>
    DailyFeedModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => DailyFeedData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DailyFeedModelToJson(DailyFeedModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

DailyFeedData _$DailyFeedDataFromJson(Map<String, dynamic> json) =>
    DailyFeedData(
      id: json['id'] as String?,
      day: json['day'] as String?,
      createdAt: json['createdAt'] as String?,
      author: json['author'] == null
          ? null
          : Author.fromJson(json['author'] as Map<String, dynamic>),
      forecast: json['forecast'] == null
          ? null
          : Forecast.fromJson(json['forecast'] as Map<String, dynamic>),
      reflection: json['reflection'] == null
          ? null
          : Reflection.fromJson(json['reflection'] as Map<String, dynamic>),
      isForecastShared: json['isForecastShared'] as bool?,
      isReflectionShared: json['isReflectionShared'] as bool?,
      likesCount: (json['likesCount'] as num?)?.toInt(),
      likedByMe: json['likedByMe'] as bool?,
      commentsCount: (json['commentsCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DailyFeedDataToJson(DailyFeedData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'createdAt': instance.createdAt,
      'author': instance.author,
      'forecast': instance.forecast,
      'reflection': instance.reflection,
      'isForecastShared': instance.isForecastShared,
      'isReflectionShared': instance.isReflectionShared,
      'likesCount': instance.likesCount,
      'likedByMe': instance.likedByMe,
      'commentsCount': instance.commentsCount,
    };

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  id: json['id'] as String?,
  username: json['username'] as String?,
  aliasName: json['aliasName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'aliasName': instance.aliasName,
  'avatarUrl': instance.avatarUrl,
  'email': instance.email,
};

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
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

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'emotions': instance.emotions,
  'plan': instance.plan,
  'notes': instance.notes,
  'userNotes': instance.userNotes,
  'createdAt': instance.createdAt,
};

Reflection _$ReflectionFromJson(Map<String, dynamic> json) => Reflection(
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  wentAsForecast: json['wentAsForecast'] as bool?,
  compareToForecast: (json['compareToForecast'] as num?)?.toInt(),
  planUseful: json['planUseful'] as bool?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$ReflectionToJson(Reflection instance) =>
    <String, dynamic>{
      'emotions': instance.emotions,
      'wentAsForecast': instance.wentAsForecast,
      'compareToForecast': instance.compareToForecast,
      'planUseful': instance.planUseful,
      'createdAt': instance.createdAt,
    };

Emotion _$EmotionFromJson(Map<String, dynamic> json) => Emotion(
  key: json['key'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  title: json['title'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$EmotionToJson(Emotion instance) => <String, dynamic>{
  'key': instance.key,
  'intensity': instance.intensity,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
};

UserNote _$UserNoteFromJson(Map<String, dynamic> json) => UserNote(
  id: json['id'] as String?,
  type: json['type'] as String?,
  day: json['day'] as String?,
  content: json['content'] as String?,
  createdAt: json['createdAt'] as String?,
  postedLabel: json['postedLabel'] as String?,
  isPrivate: json['isPrivate'] as bool?,
  isAspire: json['isAspire'] as bool?,
  likes: (json['likes'] as num?)?.toInt(),
  comments: (json['comments'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserNoteToJson(UserNote instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'day': instance.day,
  'content': instance.content,
  'createdAt': instance.createdAt,
  'postedLabel': instance.postedLabel,
  'isPrivate': instance.isPrivate,
  'isAspire': instance.isAspire,
  'likes': instance.likes,
  'comments': instance.comments,
};
