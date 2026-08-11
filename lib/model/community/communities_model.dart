import 'package:json_annotation/json_annotation.dart';

part 'communities_model.g.dart';

@JsonSerializable()
class CommunitiesModel {
  final bool? success;
  final String? message;
  final List<CommunityData>? data;

  CommunitiesModel({this.success, this.message, this.data});

  factory CommunitiesModel.fromJson(Map<String, dynamic> json) =>
      _$CommunitiesModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommunitiesModelToJson(this);
}

@JsonSerializable()
class CommunityData {
  final Community? community;
  final String? role;
  final String? status;
  final bool? isOwner;
  final Owner? owner;

  CommunityData({
    this.community,
    this.role,
    this.status,
    this.isOwner,
    this.owner,
  });

  factory CommunityData.fromJson(Map<String, dynamic> json) =>
      _$CommunityDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityDataToJson(this);
}

@JsonSerializable()
class Community {
  final String? id;
  String? name;
  String? description;
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
