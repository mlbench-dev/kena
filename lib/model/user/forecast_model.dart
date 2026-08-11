class ForecastModel {
  bool? success;
  String? message;
  List<ForecastData>? data;

  ForecastModel({this.success, this.message, this.data});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)
          ?.map((e) => ForecastData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

class ForecastData {
  String? day;
  Forecast? forecast;

  ForecastData({this.day, this.forecast});

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      day: json['day'],
      forecast: json['forecast'] != null
          ? Forecast.fromJson(json['forecast'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'day': day, 'forecast': forecast?.toJson()};
}

class Forecast {
  List<Emotion>? emotions;
  String? plan;
  String? notes;
  String? createdAt;

  Forecast({this.emotions, this.plan, this.notes, this.createdAt});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      emotions: (json['emotions'] as List?)
          ?.map((e) => Emotion.fromJson(e))
          .toList(),
      plan: json['plan'],
      notes: json['notes'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'emotions': emotions?.map((e) => e.toJson()).toList(),
    'plan': plan,
    'notes': notes,
    'createdAt': createdAt,
  };
}

class Emotion {
  String? key;
  int? intensity;
  String? imageUrl;

  Emotion({this.key, this.intensity, this.imageUrl});

  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      key: json['key'],
      intensity: json['intensity'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'intensity': intensity,
    'imageUrl': imageUrl,
  };
}
