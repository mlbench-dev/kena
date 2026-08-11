import 'package:json_annotation/json_annotation.dart';

part 'user_community.g.dart';

@JsonSerializable()
class UserCommunity {
  final bool? success;
  final String? message;
  final List<CommunityData>? data;

  UserCommunity({this.success, this.message, this.data});

  factory UserCommunity.fromJson(Map<String, dynamic> json) =>
      _$UserCommunityFromJson(json);

  Map<String, dynamic> toJson() => _$UserCommunityToJson(this);
}

@JsonSerializable()
class CommunityData {
  final Community? community;
  final Owner? owner;
  final int? maxMembers;
  final int? memberCount;
  final int? slotsRemaining;
  final int? unreadNotifications;
  final List<Member>? members;
  final List<dynamic>? pendingInvites;

  CommunityData({
    this.community,
    this.owner,
    this.maxMembers,
    this.memberCount,
    this.slotsRemaining,
    this.unreadNotifications,
    this.members,
    this.pendingInvites,
  });

  factory CommunityData.fromJson(Map<String, dynamic> json) =>
      _$CommunityDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityDataToJson(this);
}

@JsonSerializable()
class Community {
  final String? id;
  final String? name;
  final String? description;
  final String? inviteToken;
  final String? inviteUrl;

  Community({
    this.id,
    this.name,
    this.description,
    this.inviteToken,
    this.inviteUrl,
  });

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityToJson(this);
}

@JsonSerializable()
class Owner {
  final String? id;
  final String? username;
  final String? aliasName;
  final String? avatarUrl;
  final String? email;

  Owner({this.id, this.username, this.aliasName, this.avatarUrl, this.email});

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}

@JsonSerializable()
class Member {
  final String? id;
  final String? role;
  final String? status;
  final String? approvedAt;
  final Owner? user;

  Member({this.id, this.role, this.status, this.approvedAt, this.user});

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}
