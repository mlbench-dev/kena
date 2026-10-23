import 'package:json_annotation/json_annotation.dart';

part 'bulk_invite_model.g.dart';

/// Response of POST /api/community/invite/username and /invite/email.
/// Both endpoints accept a list of recipients and report per-recipient results.
@JsonSerializable(explicitToJson: true)
class BulkInviteModel {
  final bool? success;
  final String? message;
  final List<BulkInviteData>? data;

  BulkInviteModel({this.success, this.message, this.data});

  factory BulkInviteModel.fromJson(Map<String, dynamic> json) =>
      _$BulkInviteModelFromJson(json);

  Map<String, dynamic> toJson() => _$BulkInviteModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BulkInviteData {
  final List<BulkInviteSent>? sent;
  final List<BulkInviteFailed>? failed;
  final int? totalSent;
  final int? totalFailed;

  BulkInviteData({this.sent, this.failed, this.totalSent, this.totalFailed});

  factory BulkInviteData.fromJson(Map<String, dynamic> json) =>
      _$BulkInviteDataFromJson(json);

  Map<String, dynamic> toJson() => _$BulkInviteDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BulkInviteSent {
  final String? id;
  final String? token;
  final String? status;
  final BulkInviteInvitee? invitee;

  BulkInviteSent({this.id, this.token, this.status, this.invitee});

  factory BulkInviteSent.fromJson(Map<String, dynamic> json) =>
      _$BulkInviteSentFromJson(json);

  Map<String, dynamic> toJson() => _$BulkInviteSentToJson(this);
}

@JsonSerializable()
class BulkInviteInvitee {
  final String? username;
  final String? email;

  BulkInviteInvitee({this.username, this.email});

  factory BulkInviteInvitee.fromJson(Map<String, dynamic> json) =>
      _$BulkInviteInviteeFromJson(json);

  Map<String, dynamic> toJson() => _$BulkInviteInviteeToJson(this);
}

@JsonSerializable()
class BulkInviteFailed {
  final String? username;
  final String? email;
  final int? status;
  final String? message;

  BulkInviteFailed({this.username, this.email, this.status, this.message});

  factory BulkInviteFailed.fromJson(Map<String, dynamic> json) =>
      _$BulkInviteFailedFromJson(json);

  Map<String, dynamic> toJson() => _$BulkInviteFailedToJson(this);
}
