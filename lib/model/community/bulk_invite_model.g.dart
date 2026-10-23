// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_invite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BulkInviteModel _$BulkInviteModelFromJson(Map<String, dynamic> json) =>
    BulkInviteModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BulkInviteData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BulkInviteModelToJson(BulkInviteModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

BulkInviteData _$BulkInviteDataFromJson(Map<String, dynamic> json) =>
    BulkInviteData(
      sent: (json['sent'] as List<dynamic>?)
          ?.map((e) => BulkInviteSent.fromJson(e as Map<String, dynamic>))
          .toList(),
      failed: (json['failed'] as List<dynamic>?)
          ?.map((e) => BulkInviteFailed.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalSent: (json['totalSent'] as num?)?.toInt(),
      totalFailed: (json['totalFailed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BulkInviteDataToJson(BulkInviteData instance) =>
    <String, dynamic>{
      'sent': instance.sent?.map((e) => e.toJson()).toList(),
      'failed': instance.failed?.map((e) => e.toJson()).toList(),
      'totalSent': instance.totalSent,
      'totalFailed': instance.totalFailed,
    };

BulkInviteSent _$BulkInviteSentFromJson(Map<String, dynamic> json) =>
    BulkInviteSent(
      id: json['id'] as String?,
      token: json['token'] as String?,
      status: json['status'] as String?,
      invitee: json['invitee'] == null
          ? null
          : BulkInviteInvitee.fromJson(json['invitee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BulkInviteSentToJson(BulkInviteSent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'status': instance.status,
      'invitee': instance.invitee?.toJson(),
    };

BulkInviteInvitee _$BulkInviteInviteeFromJson(Map<String, dynamic> json) =>
    BulkInviteInvitee(
      username: json['username'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$BulkInviteInviteeToJson(BulkInviteInvitee instance) =>
    <String, dynamic>{'username': instance.username, 'email': instance.email};

BulkInviteFailed _$BulkInviteFailedFromJson(Map<String, dynamic> json) =>
    BulkInviteFailed(
      username: json['username'] as String?,
      email: json['email'] as String?,
      status: (json['status'] as num?)?.toInt(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$BulkInviteFailedToJson(BulkInviteFailed instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'status': instance.status,
      'message': instance.message,
    };
