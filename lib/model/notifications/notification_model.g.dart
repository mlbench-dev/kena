// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NotificationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    NotificationData(
      unreadCount: (json['unreadCount'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationDataToJson(NotificationData instance) =>
    <String, dynamic>{
      'unreadCount': instance.unreadCount,
      'items': instance.items,
    };

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      actor: json['actor'] == null
          ? null
          : Actor.fromJson(json['actor'] as Map<String, dynamic>),
      type: json['type'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] == null
          ? null
          : NotificationPayload.fromJson(json['data'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      version: (json['__v'] as num?)?.toInt(),
      readAt: json['readAt'] as String?,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'actor': instance.actor,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.version,
      'readAt': instance.readAt,
    };

Actor _$ActorFromJson(Map<String, dynamic> json) => Actor(
  id: json['_id'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String?,
  aliasName: json['aliasName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$ActorToJson(Actor instance) => <String, dynamic>{
  '_id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'aliasName': instance.aliasName,
  'avatarUrl': instance.avatarUrl,
};

NotificationPayload _$NotificationPayloadFromJson(Map<String, dynamic> json) =>
    NotificationPayload(
      inviteToken: json['inviteToken'] as String?,
      communityId: json['communityId'] as String?,
      memberUserId: json['memberUserId'] as String?,
      inviteId: json['inviteId'] as String?,
      inviterUserId: json['inviterUserId'] as String?,
    );

Map<String, dynamic> _$NotificationPayloadToJson(
  NotificationPayload instance,
) => <String, dynamic>{
  'inviteToken': instance.inviteToken,
  'communityId': instance.communityId,
  'memberUserId': instance.memberUserId,
  'inviteId': instance.inviteId,
  'inviterUserId': instance.inviterUserId,
};
