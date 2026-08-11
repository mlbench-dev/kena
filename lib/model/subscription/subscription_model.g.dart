// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SubscriptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

SubscriptionData _$SubscriptionDataFromJson(Map<String, dynamic> json) =>
    SubscriptionData(
      hasSubscription: json['hasSubscription'] as bool?,
      status: json['status'] as String?,
      priceId: json['priceId'] as String?,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool?,
      currentPeriodEnd: json['currentPeriodEnd'] as String?,
      trialEnd: json['trialEnd'] as String?,
      willRenew: json['willRenew'] as bool?,
      isActive: json['isActive'] as bool?,
      isTrial: json['isTrial'] as bool?,
      subscriptionType: json['subscriptionType'] as String?,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt(),
      price: json['price'] == null
          ? null
          : Price.fromJson(json['price'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscriptionDataToJson(SubscriptionData instance) =>
    <String, dynamic>{
      'hasSubscription': instance.hasSubscription,
      'status': instance.status,
      'priceId': instance.priceId,
      'cancelAtPeriodEnd': instance.cancelAtPeriodEnd,
      'currentPeriodEnd': instance.currentPeriodEnd,
      'trialEnd': instance.trialEnd,
      'willRenew': instance.willRenew,
      'isActive': instance.isActive,
      'isTrial': instance.isTrial,
      'subscriptionType': instance.subscriptionType,
      'daysRemaining': instance.daysRemaining,
      'price': instance.price,
    };

Price _$PriceFromJson(Map<String, dynamic> json) => Price(
  priceId: json['priceId'] as String?,
  name: json['name'] as String?,
  unitAmount: (json['unitAmount'] as num?)?.toInt(),
  unitAmountDecimal: json['unitAmountDecimal'] as String?,
  currency: json['currency'] as String?,
  interval: json['interval'] as String?,
  intervalCount: (json['intervalCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$PriceToJson(Price instance) => <String, dynamic>{
  'priceId': instance.priceId,
  'name': instance.name,
  'unitAmount': instance.unitAmount,
  'unitAmountDecimal': instance.unitAmountDecimal,
  'currency': instance.currency,
  'interval': instance.interval,
  'intervalCount': instance.intervalCount,
};
