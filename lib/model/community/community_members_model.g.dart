// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_members_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityMembers _$CommunityMembersFromJson(Map<String, dynamic> json) =>
    CommunityMembers(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MemberData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommunityMembersToJson(CommunityMembers instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

MemberData _$MemberDataFromJson(Map<String, dynamic> json) => MemberData(
  id: json['id'] as String?,
  username: json['username'] as String?,
  aliasName: json['aliasName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$MemberDataToJson(MemberData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'aliasName': instance.aliasName,
      'avatarUrl': instance.avatarUrl,
    };
