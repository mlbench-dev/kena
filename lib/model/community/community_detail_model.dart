import 'package:json_annotation/json_annotation.dart';

part 'community_detail_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommunityDetailModel {
  bool? success;
  String? message;
  List<CommunityDetailData>? data;

  CommunityDetailModel({this.success, this.message, this.data});

  factory CommunityDetailModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityDetailModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CommunityDetailData {
  Community? community;
  Owner? owner;

  int? maxMembers;
  int? memberCount;
  int? slotsRemaining;
  int? unreadNotifications;

  List<Participant>? participants;
  List<Member>? members;

  List<PendingInvite>? pendingInvites;

  CommunityDetailData({
    this.community,
    this.owner,
    this.maxMembers,
    this.memberCount,
    this.slotsRemaining,
    this.unreadNotifications,
    this.participants,
    this.members,
    this.pendingInvites,
  });

  factory CommunityDetailData.fromJson(Map<String, dynamic> json) =>
      _$CommunityDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityDetailDataToJson(this);
}

@JsonSerializable()
class Community {
  String? id;
  String? name;
  String? description;

  Community({this.id, this.name, this.description});

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityToJson(this);
}

@JsonSerializable()
class Owner {
  String? id;
  String? username;
  String? aliasName;
  String? avatarUrl;
  String? email;

  Owner({this.id, this.username, this.aliasName, this.avatarUrl, this.email});

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Participant {
  String? id;
  String? role;
  String? status;
  String? approvedAt;
  Owner? user;

  Participant({this.id, this.role, this.status, this.approvedAt, this.user});

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Member {
  String? id;
  String? role;
  String? status;
  String? approvedAt;
  Owner? user;

  Member({this.id, this.role, this.status, this.approvedAt, this.user});

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PendingInvite {
  String? id;
  String? token;
  String? channel;
  String? status;
  String? inviteeEmail;
  String? inviteeUsername;
  String? sentAt;
  String? inviteUrl;
  Owner? invitee;

  PendingInvite({
    this.id,
    this.token,
    this.channel,
    this.status,
    this.inviteeEmail,
    this.inviteeUsername,
    this.sentAt,
    this.inviteUrl,
    this.invitee,
  });

  factory PendingInvite.fromJson(Map<String, dynamic> json) =>
      _$PendingInviteFromJson(json);

  Map<String, dynamic> toJson() => _$PendingInviteToJson(this);
}
