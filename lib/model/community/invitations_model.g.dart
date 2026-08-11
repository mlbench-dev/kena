// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitations_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationsModel _$InvitationsModelFromJson(Map<String, dynamic> json) =>
    InvitationsModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>)
                .map((e) => Invitation.fromJson(e as Map<String, dynamic>))
                .toList(),
          )
          .toList(),
    );

Map<String, dynamic> _$InvitationsModelToJson(
  InvitationsModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.map((e) => e.toJson()).toList()).toList(),
};

Invitation _$InvitationFromJson(Map<String, dynamic> json) => Invitation(
  id: json['id'] as String?,
  token: json['token'] as String?,
  channel: json['channel'] as String?,
  status: json['status'] as String?,
  sentAt: json['sentAt'] as String?,
  respondedAt: json['respondedAt'] as String?,
  inviteUrl: json['inviteUrl'] as String?,
  inviteeEmail: json['inviteeEmail'] as String?,
  inviteeEmailMasked: json['inviteeEmailMasked'] as String?,
  inviteeUsername: json['inviteeUsername'] as String?,
  inviter: json['inviter'] == null
      ? null
      : Inviter.fromJson(json['inviter'] as Map<String, dynamic>),
  community: json['community'] == null
      ? null
      : Community.fromJson(json['community'] as Map<String, dynamic>),
);

Map<String, dynamic> _$InvitationToJson(Invitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'channel': instance.channel,
      'status': instance.status,
      'sentAt': instance.sentAt,
      'respondedAt': instance.respondedAt,
      'inviteUrl': instance.inviteUrl,
      'inviteeEmail': instance.inviteeEmail,
      'inviteeEmailMasked': instance.inviteeEmailMasked,
      'inviteeUsername': instance.inviteeUsername,
      'inviter': instance.inviter?.toJson(),
      'community': instance.community?.toJson(),
    };

Inviter _$InviterFromJson(Map<String, dynamic> json) => Inviter(
  id: json['id'] as String?,
  username: json['username'] as String?,
  aliasName: json['aliasName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$InviterToJson(Inviter instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'aliasName': instance.aliasName,
  'avatarUrl': instance.avatarUrl,
  'email': instance.email,
};

Community _$CommunityFromJson(Map<String, dynamic> json) => Community(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$CommunityToJson(Community instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
};
