import 'package:json_annotation/json_annotation.dart';

part 'invite_link_model.g.dart';

@JsonSerializable()
class InviteLinkModel {
  final bool? success;
  final String? message;
  final List<InviteLinkData>? data;

  InviteLinkModel({this.success, this.message, this.data});

  factory InviteLinkModel.fromJson(Map<String, dynamic> json) =>
      _$InviteLinkModelFromJson(json);

  Map<String, dynamic> toJson() => _$InviteLinkModelToJson(this);
}

@JsonSerializable()
class InviteLinkData {
  final String? communityId;
  final String? token;
  final String? url;

  InviteLinkData({this.communityId, this.token, this.url});

  factory InviteLinkData.fromJson(Map<String, dynamic> json) =>
      _$InviteLinkDataFromJson(json);

  Map<String, dynamic> toJson() => _$InviteLinkDataToJson(this);
}
