import 'package:json_annotation/json_annotation.dart';

part 'feed_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FeedModel {
  bool? success;
  String? message;
  List<Data>? data;

  FeedModel({this.success, this.message, this.data});

  factory FeedModel.fromJson(Map<String, dynamic> json) =>
      _$FeedModelFromJson(json);
  Map<String, dynamic> toJson() => _$FeedModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Data {
  String? id;
  String? day;
  String? createdAt;
  Author? author;
  Forecast? forecast;
  Reflection? reflection;
  int? likesCount;
  bool? likedByMe;
  int? commentsCount;
  List<Comment>? comments;

  Data({
    this.id,
    this.day,
    this.createdAt,
    this.author,
    this.forecast,
    this.reflection,
    this.likesCount,
    this.likedByMe,
    this.commentsCount,
    this.comments,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class Author {
  String? id;
  String? username;
  String? aliasName;
  String? avatarUrl;
  String? email;

  Author({this.id, this.username, this.aliasName, this.avatarUrl, this.email});

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Forecast {
  List<Emotions>? emotions;
  String? plan;
  String? createdAt;
  String? notes;

  Forecast({this.emotions, this.plan, this.createdAt, this.notes});

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);
  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable()
class Emotions {
  String? key;
  int? intensity;
  String? imageUrl;

  Emotions({this.key, this.intensity, this.imageUrl});

  factory Emotions.fromJson(Map<String, dynamic> json) =>
      _$EmotionsFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Reflection {
  List<Emotions>? emotions;
  bool? wentAsForecast;
  int? compareToForecast;
  bool? planUseful;
  String? planFeedback;
  String? createdAt;
  String? why;

  Reflection({
    this.emotions,
    this.wentAsForecast,
    this.compareToForecast,
    this.planUseful,
    this.planFeedback,
    this.createdAt,
    this.why,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) =>
      _$ReflectionFromJson(json);
  Map<String, dynamic> toJson() => _$ReflectionToJson(this);
}

@JsonSerializable()
class Comment {
  String? id;
  String? content;
  Author? user;
  String? createdAt;

  Comment({this.id, this.content, this.user, this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
