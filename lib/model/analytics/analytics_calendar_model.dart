import 'package:json_annotation/json_annotation.dart';

part 'analytics_calendar_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AnalyticsCalendarModel {
  bool? success;
  String? message;
  List<Data>? data;

  AnalyticsCalendarModel({this.success, this.message, this.data});

  factory AnalyticsCalendarModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsCalendarModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsCalendarModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Data {
  String? day;
  bool? hasEntry;
  List<CoreEmotions>? coreEmotions;
  List<AspirationalEmotions>? aspirationalEmotions;
  List<Forecast>? forecast;

  // Original generator produced `List<Null>` for an empty/always-null JSON
  // array. `Null` isn't a usable model type, so this is normalized to
  // `List<dynamic>?`. Replace `dynamic` with a concrete model class once you
  // know the real shape of the "actual" entries.
  List<dynamic>? actual;

  Plan? plan;
  List<Notes>? notes;
  RawNotes? rawNotes;

  Data({
    this.day,
    this.hasEntry,
    this.coreEmotions,
    this.aspirationalEmotions,
    this.forecast,
    this.actual,
    this.plan,
    this.notes,
    this.rawNotes,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CoreEmotions {
  String? key;
  String? name;
  String? imageUrl;
  int? intensity;
  String? intensityLabel;

  CoreEmotions({
    this.key,
    this.name,
    this.imageUrl,
    this.intensity,
    this.intensityLabel,
  });

  factory CoreEmotions.fromJson(Map<String, dynamic> json) =>
      _$CoreEmotionsFromJson(json);

  Map<String, dynamic> toJson() => _$CoreEmotionsToJson(this);
}

// `aspirationalEmotions` was referenced in the original `Data` class but
// its model was never defined in the source file. It is assumed to mirror
// `CoreEmotions` (same shape as it appears in the same "emotions" list
// pattern). Adjust the fields below if the real API shape differs.
@JsonSerializable(explicitToJson: true)
class AspirationalEmotions {
  String? key;
  String? name;
  String? imageUrl;
  int? intensity;
  String? intensityLabel;

  AspirationalEmotions({
    this.key,
    this.name,
    this.imageUrl,
    this.intensity,
    this.intensityLabel,
  });

  factory AspirationalEmotions.fromJson(Map<String, dynamic> json) =>
      _$AspirationalEmotionsFromJson(json);

  Map<String, dynamic> toJson() => _$AspirationalEmotionsToJson(this);
}

// `forecast` was referenced in the original `Data` class but its model was
// never defined in the source file. It is assumed to mirror `CoreEmotions`
// since it sits alongside `actual` as a parallel emotion-intensity series.
// Adjust the fields below if the real API shape differs.
@JsonSerializable(explicitToJson: true)
class Forecast {
  String? key;
  String? name;
  String? imageUrl;
  int? intensity;
  String? intensityLabel;

  Forecast({
    this.key,
    this.name,
    this.imageUrl,
    this.intensity,
    this.intensityLabel,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Plan {
  String? text;

  Plan({this.text});

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);

  Map<String, dynamic> toJson() => _$PlanToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Notes {
  @JsonKey(name: '_id')
  String? id;
  String? type;
  String? day;
  String? content;
  String? createdAt;
  String? postedLabel;
  bool? isPrivate;
  bool? isAspire;
  int? likes;
  int? comments;

  Notes({
    this.id,
    this.type,
    this.day,
    this.content,
    this.createdAt,
    this.postedLabel,
    this.isPrivate,
    this.isAspire,
    this.likes,
    this.comments,
  });

  factory Notes.fromJson(Map<String, dynamic> json) => _$NotesFromJson(json);

  Map<String, dynamic> toJson() => _$NotesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawNotes {
  // Original generator produced `Null` for these (always-null in the
  // sample JSON). Normalized to `dynamic?` since a raw null value can't be
  // typed as `Null`. Replace `dynamic` with a concrete model class once you
  // know the real shape of "forecast"/"daily" here.
  dynamic forecast;
  dynamic daily;

  RawNotes({this.forecast, this.daily});

  factory RawNotes.fromJson(Map<String, dynamic> json) =>
      _$RawNotesFromJson(json);

  Map<String, dynamic> toJson() => _$RawNotesToJson(this);
}
