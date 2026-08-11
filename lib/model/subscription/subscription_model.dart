import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionModel {
  final bool? success;
  final String? message;
  final List<SubscriptionData>? data;

  SubscriptionModel({this.success, this.message, this.data});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);
}

@JsonSerializable()
class SubscriptionData {
  final bool? hasSubscription;
  final String? status;
  final String? priceId;
  final bool? cancelAtPeriodEnd;
  final String? currentPeriodEnd;
  final String? trialEnd; // FIXED
  final bool? willRenew;
  final bool? isActive;
  final bool? isTrial;
  final String? subscriptionType;
  final int? daysRemaining;
  final Price? price;

  SubscriptionData({
    this.hasSubscription,
    this.status,
    this.priceId,
    this.cancelAtPeriodEnd,
    this.currentPeriodEnd,
    this.trialEnd,
    this.willRenew,
    this.isActive,
    this.isTrial,
    this.subscriptionType,
    this.daysRemaining,
    this.price,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionDataToJson(this);
}

@JsonSerializable()
class Price {
  final String? priceId;
  final String? name;
  final int? unitAmount;
  final String? unitAmountDecimal;
  final String? currency;
  final String? interval;
  final int? intervalCount;

  Price({
    this.priceId,
    this.name,
    this.unitAmount,
    this.unitAmountDecimal,
    this.currency,
    this.interval,
    this.intervalCount,
  });

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

  Map<String, dynamic> toJson() => _$PriceToJson(this);
}
