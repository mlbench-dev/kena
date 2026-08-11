import 'package:json_annotation/json_annotation.dart';

part 'community_members_model.g.dart';

@JsonSerializable()
class CommunityMembers {
  bool? success;
  String? message;
  List<MemberData>? data;

  CommunityMembers({this.success, this.message, this.data});

  factory CommunityMembers.fromJson(Map<String, dynamic> json) =>
      _$CommunityMembersFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityMembersToJson(this);
}

@JsonSerializable()
class MemberData {
  String? id;
  String? username;
  String? aliasName;
  String? avatarUrl;

  MemberData({this.id, this.username, this.aliasName, this.avatarUrl});

  factory MemberData.fromJson(Map<String, dynamic> json) {
    final member = _$MemberDataFromJson(json);
    member.id =
        member.id ?? json['_id'] as String? ?? json['userId'] as String?;
    return member;
  }

  Map<String, dynamic> toJson() => _$MemberDataToJson(this);
}
