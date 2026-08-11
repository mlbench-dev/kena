// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_calendar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsCalendarModel _$AnalyticsCalendarModelFromJson(
  Map<String, dynamic> json,
) => AnalyticsCalendarModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => Data.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AnalyticsCalendarModelToJson(
  AnalyticsCalendarModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  day: json['day'] as String?,
  hasEntry: json['hasEntry'] as bool?,
  coreEmotions: (json['coreEmotions'] as List<dynamic>?)
      ?.map((e) => CoreEmotions.fromJson(e as Map<String, dynamic>))
      .toList(),
  aspirationalEmotions: (json['aspirationalEmotions'] as List<dynamic>?)
      ?.map((e) => AspirationalEmotions.fromJson(e as Map<String, dynamic>))
      .toList(),
  forecast: (json['forecast'] as List<dynamic>?)
      ?.map((e) => Forecast.fromJson(e as Map<String, dynamic>))
      .toList(),
  actual: json['actual'] as List<dynamic>?,
  plan: json['plan'] == null
      ? null
      : Plan.fromJson(json['plan'] as Map<String, dynamic>),
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => Notes.fromJson(e as Map<String, dynamic>))
      .toList(),
  rawNotes: json['rawNotes'] == null
      ? null
      : RawNotes.fromJson(json['rawNotes'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'day': instance.day,
  'hasEntry': instance.hasEntry,
  'coreEmotions': instance.coreEmotions?.map((e) => e.toJson()).toList(),
  'aspirationalEmotions': instance.aspirationalEmotions
      ?.map((e) => e.toJson())
      .toList(),
  'forecast': instance.forecast?.map((e) => e.toJson()).toList(),
  'actual': instance.actual,
  'plan': instance.plan?.toJson(),
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
  'rawNotes': instance.rawNotes?.toJson(),
};

CoreEmotions _$CoreEmotionsFromJson(Map<String, dynamic> json) => CoreEmotions(
  key: json['key'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  intensityLabel: json['intensityLabel'] as String?,
);

Map<String, dynamic> _$CoreEmotionsToJson(CoreEmotions instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'intensity': instance.intensity,
      'intensityLabel': instance.intensityLabel,
    };

AspirationalEmotions _$AspirationalEmotionsFromJson(
  Map<String, dynamic> json,
) => AspirationalEmotions(
  key: json['key'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  intensityLabel: json['intensityLabel'] as String?,
);

Map<String, dynamic> _$AspirationalEmotionsToJson(
  AspirationalEmotions instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'intensity': instance.intensity,
  'intensityLabel': instance.intensityLabel,
};

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
  key: json['key'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  intensityLabel: json['intensityLabel'] as String?,
);

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'intensity': instance.intensity,
  'intensityLabel': instance.intensityLabel,
};

Plan _$PlanFromJson(Map<String, dynamic> json) =>
    Plan(text: json['text'] as String?);

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
  'text': instance.text,
};

Notes _$NotesFromJson(Map<String, dynamic> json) => Notes(
  id: json['_id'] as String?,
  type: json['type'] as String?,
  day: json['day'] as String?,
  content: json['content'] as String?,
  createdAt: json['createdAt'] as String?,
  postedLabel: json['postedLabel'] as String?,
  isPrivate: json['isPrivate'] as bool?,
  isAspire: json['isAspire'] as bool?,
  likes: (json['likes'] as num?)?.toInt(),
  comments: (json['comments'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotesToJson(Notes instance) => <String, dynamic>{
  '_id': instance.id,
  'type': instance.type,
  'day': instance.day,
  'content': instance.content,
  'createdAt': instance.createdAt,
  'postedLabel': instance.postedLabel,
  'isPrivate': instance.isPrivate,
  'isAspire': instance.isAspire,
  'likes': instance.likes,
  'comments': instance.comments,
};

RawNotes _$RawNotesFromJson(Map<String, dynamic> json) =>
    RawNotes(forecast: json['forecast'], daily: json['daily']);

Map<String, dynamic> _$RawNotesToJson(RawNotes instance) => <String, dynamic>{
  'forecast': instance.forecast,
  'daily': instance.daily,
};
