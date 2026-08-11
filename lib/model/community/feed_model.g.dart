// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedModel _$FeedModelFromJson(Map<String, dynamic> json) => FeedModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => Data.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FeedModelToJson(FeedModel instance) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

Data _$DataFromJson(Map<String, dynamic> json) => Data(
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
  likesCount: (json['likesCount'] as num?)?.toInt(),
  likedByMe: json['likedByMe'] as bool?,
  commentsCount: (json['commentsCount'] as num?)?.toInt(),
  comments: (json['comments'] as List<dynamic>?)
      ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'id': instance.id,
  'day': instance.day,
  'createdAt': instance.createdAt,
  'author': instance.author?.toJson(),
  'forecast': instance.forecast?.toJson(),
  'reflection': instance.reflection?.toJson(),
  'likesCount': instance.likesCount,
  'likedByMe': instance.likedByMe,
  'commentsCount': instance.commentsCount,
  'comments': instance.comments?.map((e) => e.toJson()).toList(),
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
      ?.map((e) => Emotions.fromJson(e as Map<String, dynamic>))
      .toList(),
  plan: json['plan'] as String?,
  createdAt: json['createdAt'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'emotions': instance.emotions?.map((e) => e.toJson()).toList(),
  'plan': instance.plan,
  'createdAt': instance.createdAt,
  'notes': instance.notes,
};

Emotions _$EmotionsFromJson(Map<String, dynamic> json) => Emotions(
  key: json['key'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$EmotionsToJson(Emotions instance) => <String, dynamic>{
  'key': instance.key,
  'intensity': instance.intensity,
  'imageUrl': instance.imageUrl,
};

Reflection _$ReflectionFromJson(Map<String, dynamic> json) => Reflection(
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => Emotions.fromJson(e as Map<String, dynamic>))
      .toList(),
  wentAsForecast: json['wentAsForecast'] as bool?,
  compareToForecast: (json['compareToForecast'] as num?)?.toInt(),
  planUseful: json['planUseful'] as bool?,
  planFeedback: json['planFeedback'] as String?,
  createdAt: json['createdAt'] as String?,
  why: json['why'] as String?,
);

Map<String, dynamic> _$ReflectionToJson(Reflection instance) =>
    <String, dynamic>{
      'emotions': instance.emotions?.map((e) => e.toJson()).toList(),
      'wentAsForecast': instance.wentAsForecast,
      'compareToForecast': instance.compareToForecast,
      'planUseful': instance.planUseful,
      'planFeedback': instance.planFeedback,
      'createdAt': instance.createdAt,
      'why': instance.why,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String?,
  content: json['content'] as String?,
  user: json['user'] == null
      ? null
      : Author.fromJson(json['user'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'user': instance.user,
  'createdAt': instance.createdAt,
};
