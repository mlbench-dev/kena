import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final bool? success;
  final String? message;
  final List<NotificationData>? data;

  NotificationModel({this.success, this.message, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable()
class NotificationData {
  final int? unreadCount;
  final List<NotificationItem>? items;

  NotificationData({this.unreadCount, this.items});

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDataToJson(this);
}

@JsonSerializable()
class NotificationItem {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'user_id')
  final String? userId;

  final Actor? actor;

  final String? type;
  final String? title;
  final String? body;

  final NotificationPayload? data;

  final String? createdAt;
  final String? updatedAt;

  @JsonKey(name: '__v')
  final int? version;

  final String? readAt;

  NotificationItem({
    this.id,
    this.userId,
    this.actor,
    this.type,
    this.title,
    this.body,
    this.data,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

@JsonSerializable()
class Actor {
  @JsonKey(name: '_id')
  final String? id;

  final String? username;
  final String? email;
  final String? aliasName;
  final String? avatarUrl;

  Actor({this.id, this.username, this.email, this.aliasName, this.avatarUrl});

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);

  Map<String, dynamic> toJson() => _$ActorToJson(this);
}

@JsonSerializable()
class NotificationPayload {
  final String? inviteToken;
  final String? communityId;
  final String? memberUserId;
  final String? inviteId;
  final String? inviterUserId;

  NotificationPayload({
    this.inviteToken,
    this.communityId,
    this.memberUserId,
    this.inviteId,
    this.inviterUserId,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPayloadToJson(this);
}
