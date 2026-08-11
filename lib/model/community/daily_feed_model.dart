import 'package:json_annotation/json_annotation.dart';

part 'daily_feed_model.g.dart';

@JsonSerializable()
class DailyFeedModel {
  final bool? success;
  final String? message;
  final List<DailyFeedData>? data;

  DailyFeedModel({this.success, this.message, this.data});

  factory DailyFeedModel.fromJson(Map<String, dynamic> json) =>
      _$DailyFeedModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyFeedModelToJson(this);
}

@JsonSerializable()
class DailyFeedData {
  final String? id;
  final String? day;
  final String? createdAt;
  final Author? author;
  final Forecast? forecast;
  final Reflection? reflection;
  final bool? isForecastShared;
  final bool? isReflectionShared;
  final int? likesCount;
  final bool? likedByMe;
  final int? commentsCount;

  DailyFeedData({
    this.id,
    this.day,
    this.createdAt,
    this.author,
    this.forecast,
    this.reflection,
    this.isForecastShared,
    this.isReflectionShared,
    this.likesCount,
    this.likedByMe,
    this.commentsCount,
  });

  factory DailyFeedData.fromJson(Map<String, dynamic> json) =>
      _$DailyFeedDataFromJson(json);

  Map<String, dynamic> toJson() => _$DailyFeedDataToJson(this);
}

@JsonSerializable()
class Author {
  final String? id;
  final String? username;
  final String? aliasName;
  final String? avatarUrl;
  final String? email;

  Author({this.id, this.username, this.aliasName, this.avatarUrl, this.email});

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

@JsonSerializable()
class Forecast {
  final List<Emotion>? emotions;
  final String? plan;
  final String? notes;
  final List<UserNote>? userNotes;
  final String? createdAt;

  Forecast({this.emotions, this.plan, this.notes, this.userNotes, this.createdAt});

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable()
class Reflection {
  final List<Emotion>? emotions;
  final bool? wentAsForecast;
  final int? compareToForecast;
  final bool? planUseful;
  final String? createdAt;

  Reflection({
    this.emotions,
    this.wentAsForecast,
    this.compareToForecast,
    this.planUseful,
    this.createdAt,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) =>
      _$ReflectionFromJson(json);

  Map<String, dynamic> toJson() => _$ReflectionToJson(this);
}

/// Shared by Forecast and Reflection
@JsonSerializable()
class Emotion {
  final String? key;
  final int? intensity;
  final String? title;
  final String? imageUrl;

  Emotion({this.key, this.intensity, this.title, this.imageUrl});

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);
}

@JsonSerializable()
class UserNote {
  final String? id;
  final String? type;
  final String? day;
  final String? content;
  final String? createdAt;
  final String? postedLabel;
  final bool? isPrivate;
  final bool? isAspire;
  final int? likes;
  final int? comments;

  UserNote({
    this.id,
    this.type,
    this.day,
    this.content,
    this.createdAt,
    this.postedLabel,
    this.isPrivate,
    this.isAspire,
    this.likes,
    this.comments,
  });

  factory UserNote.fromJson(Map<String, dynamic> json) =>
      _$UserNoteFromJson(json);

  Map<String, dynamic> toJson() => _$UserNoteToJson(this);
}
