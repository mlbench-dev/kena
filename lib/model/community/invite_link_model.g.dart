// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_link_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteLinkModel _$InviteLinkModelFromJson(Map<String, dynamic> json) =>
    InviteLinkModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => InviteLinkData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InviteLinkModelToJson(InviteLinkModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

InviteLinkData _$InviteLinkDataFromJson(Map<String, dynamic> json) =>
    InviteLinkData(
      communityId: json['communityId'] as String?,
      token: json['token'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$InviteLinkDataToJson(InviteLinkData instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'token': instance.token,
      'url': instance.url,
    };
