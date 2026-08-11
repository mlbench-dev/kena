// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCommunity _$UserCommunityFromJson(Map<String, dynamic> json) =>
    UserCommunity(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CommunityData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserCommunityToJson(UserCommunity instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

CommunityData _$CommunityDataFromJson(Map<String, dynamic> json) =>
    CommunityData(
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
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingInvites: json['pendingInvites'] as List<dynamic>?,
    );

Map<String, dynamic> _$CommunityDataToJson(CommunityData instance) =>
    <String, dynamic>{
      'community': instance.community,
      'owner': instance.owner,
      'maxMembers': instance.maxMembers,
      'memberCount': instance.memberCount,
      'slotsRemaining': instance.slotsRemaining,
      'unreadNotifications': instance.unreadNotifications,
      'members': instance.members,
      'pendingInvites': instance.pendingInvites,
    };

Community _$CommunityFromJson(Map<String, dynamic> json) => Community(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  inviteToken: json['inviteToken'] as String?,
  inviteUrl: json['inviteUrl'] as String?,
);

Map<String, dynamic> _$CommunityToJson(Community instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'inviteToken': instance.inviteToken,
  'inviteUrl': instance.inviteUrl,
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
  'user': instance.user,
};
