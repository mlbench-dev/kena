// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communities_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunitiesModel _$CommunitiesModelFromJson(Map<String, dynamic> json) =>
    CommunitiesModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CommunityData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommunitiesModelToJson(CommunitiesModel instance) =>
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
      role: json['role'] as String?,
      status: json['status'] as String?,
      isOwner: json['isOwner'] as bool?,
      owner: json['owner'] == null
          ? null
          : Owner.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommunityDataToJson(CommunityData instance) =>
    <String, dynamic>{
      'community': instance.community,
      'role': instance.role,
      'status': instance.status,
      'isOwner': instance.isOwner,
      'owner': instance.owner,
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
