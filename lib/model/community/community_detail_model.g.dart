// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityDetailModel _$CommunityDetailModelFromJson(
  Map<String, dynamic> json,
) => CommunityDetailModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CommunityDetailData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CommunityDetailModelToJson(
  CommunityDetailModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

CommunityDetailData _$CommunityDetailDataFromJson(Map<String, dynamic> json) =>
    CommunityDetailData(
      community: json['community'] == null
          ? null
          : Community.fromJson(json['community'] as Map<String, dynamic>),
      owner: json['owner'] == null
          ? null
          : Owner.fromJson(json['owner'] as Map<String, dynamic>),
      maxMembers: (json['maxMembers'] as num?)?.toInt(),
      memberCount: (json['memberCount'] as num?)?.toInt(),
      slotsRemaining: (json['slotsRemaining'] as num?)?.toInt(),
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt(),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingInvites: (json['pendingInvites'] as List<dynamic>?)
          ?.map((e) => PendingInvite.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommunityDetailDataToJson(
  CommunityDetailData instance,
) => <String, dynamic>{
  'community': instance.community?.toJson(),
  'owner': instance.owner?.toJson(),
  'maxMembers': instance.maxMembers,
  'memberCount': instance.memberCount,
  'slotsRemaining': instance.slotsRemaining,
  'unreadNotifications': instance.unreadNotifications,
  'participants': instance.participants?.map((e) => e.toJson()).toList(),
  'members': instance.members?.map((e) => e.toJson()).toList(),
  'pendingInvites': instance.pendingInvites?.map((e) => e.toJson()).toList(),
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

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
  id: json['id'] as String?,
  username: json['username'] as String?,
  aliasName: json['aliasName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'aliasName': instance.aliasName,
  'avatarUrl': instance.avatarUrl,
  'email': instance.email,
};

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
  id: json['id'] as String?,
  role: json['role'] as String?,
  status: json['status'] as String?,
  approvedAt: json['approvedAt'] as String?,
  user: json['user'] == null
      ? null
      : Owner.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'status': instance.status,
      'approvedAt': instance.approvedAt,
      'user': instance.user?.toJson(),
    };

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
  id: json['id'] as String?,
  role: json['role'] as String?,
  status: json['status'] as String?,
  approvedAt: json['approvedAt'] as String?,
  user: json['user'] == null
      ? null
      : Owner.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'status': instance.status,
  'approvedAt': instance.approvedAt,
  'user': instance.user?.toJson(),
};

PendingInvite _$PendingInviteFromJson(Map<String, dynamic> json) =>
    PendingInvite(
      id: json['id'] as String?,
      token: json['token'] as String?,
      channel: json['channel'] as String?,
      status: json['status'] as String?,
      inviteeEmail: json['inviteeEmail'] as String?,
      inviteeUsername: json['inviteeUsername'] as String?,
      sentAt: json['sentAt'] as String?,
      inviteUrl: json['inviteUrl'] as String?,
      invitee: json['invitee'] == null
          ? null
          : Owner.fromJson(json['invitee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PendingInviteToJson(PendingInvite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'channel': instance.channel,
      'status': instance.status,
      'inviteeEmail': instance.inviteeEmail,
      'inviteeUsername': instance.inviteeUsername,
      'sentAt': instance.sentAt,
      'inviteUrl': instance.inviteUrl,
      'invitee': instance.invitee?.toJson(),
    };
