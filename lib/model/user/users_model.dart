import 'package:json_annotation/json_annotation.dart';

part 'users_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final bool? success;
  final String? message;
  final List<ProfileData>? data;

  ProfileModel({this.success, this.message, this.data});

  /// Helper
  UserModel? get user => data?.isNotEmpty == true ? data!.first.user : null;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

@JsonSerializable()
class ProfileData {
  final UserModel? user;

  ProfileData({this.user});

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UserModel {
  final String? id;
  final String? username;
  final String? email;
  final String? password;
  final String? aliasName;
  final String? avatarUrl;
  final String? provider;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.password,
    this.aliasName,
    this.avatarUrl,
    this.provider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
