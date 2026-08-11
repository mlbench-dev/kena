import 'package:json_annotation/json_annotation.dart';

part 'invitations_model.g.dart';

@JsonSerializable(explicitToJson: true)
class InvitationsModel {
  final bool? success;
  final String? message;
  final List<List<Invitation>>? data;

  InvitationsModel({this.success, this.message, this.data});

  factory InvitationsModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationsModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Invitation {
  final String? id;
  final String? token;
  final String? channel;
  final String? status;
  final String? sentAt;
  final String? respondedAt;
  final String? inviteUrl;
  final String? inviteeEmail;
  final String? inviteeEmailMasked;
  final String? inviteeUsername;

  final Inviter? inviter;
  final Community? community;

  Invitation({
    this.id,
    this.token,
    this.channel,
    this.status,
    this.sentAt,
    this.respondedAt,
    this.inviteUrl,
    this.inviteeEmail,
    this.inviteeEmailMasked,
    this.inviteeUsername,
    this.inviter,
    this.community,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Inviter {
  final String? id;
  final String? username;
  final String? aliasName;
  final String? avatarUrl;
  final String? email;

  Inviter({this.id, this.username, this.aliasName, this.avatarUrl, this.email});

  factory Inviter.fromJson(Map<String, dynamic> json) =>
      _$InviterFromJson(json);

  Map<String, dynamic> toJson() => _$InviterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Community {
  final String? id;
  final String? name;
  final String? description;

  Community({this.id, this.name, this.description});

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityToJson(this);
}
