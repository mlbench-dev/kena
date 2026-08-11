class UserHomeModel {
  final bool? success;
  final String? message;
  final List<Data>? data;

  UserHomeModel({this.success, this.message, this.data});

  factory UserHomeModel.fromJson(Map<String, dynamic> json) {
    return UserHomeModel(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)?.map((e) => Data.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

// ================= DATA =================

class Data {
  final String? date;
  final User? user;
  final List<CoreEmotions>? coreEmotions;
  final List<AspirationEmotion>? aspirationEmotions;
  final Aspiration? aspiration;
  final Journal? journal;
  final List<Activity>? activities;
  final Community? community;

  Data({
    this.date,
    this.user,
    this.coreEmotions,
    this.aspirationEmotions,
    this.aspiration,
    this.journal,
    this.activities,
    this.community,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      date: json['date'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      coreEmotions: (json['coreEmotions'] as List?)
          ?.map((e) => CoreEmotions.fromJson(e))
          .toList(),
      aspirationEmotions: (json['aspirationEmotions'] as List?)
          ?.map((e) => AspirationEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspiration: json['aspiration'] != null
          ? Aspiration.fromJson(json['aspiration'])
          : null,
      journal: json['journal'] != null
          ? Journal.fromJson(json['journal'])
          : null,
      activities: (json['activities'] as List?)
          ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
      community: json['community'] != null
          ? Community.fromJson(json['community'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'user': user?.toJson(),
      'coreEmotions': coreEmotions?.map((e) => e.toJson()).toList(),
      'aspirationEmotions': aspirationEmotions?.map((e) => e.toJson()).toList(),
      'aspiration': aspiration?.toJson(),
      'journal': journal?.toJson(),
      'activities': activities?.map((e) => e.toJson()).toList(),
      'community': community?.toJson(),
    };
  }
}

// ================= USER =================

class User {
  final String? id;
  final String? username;

  User({this.id, this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], username: json['username']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username};
  }
}

// ================= CORE EMOTIONS =================

class CoreEmotions {
  final String? key;
  final String? name;
  final String? emoji;
  final int? intensity;
  final int? intensityPercent;

  CoreEmotions({
    this.key,
    this.name,
    this.emoji,
    this.intensity,
    this.intensityPercent,
  });

  factory CoreEmotions.fromJson(Map<String, dynamic> json) {
    return CoreEmotions(
      key: json['key'],
      name: json['name'],
      emoji: json['emoji'],
      intensity: json['intensity'],
      intensityPercent: json['intensityPercent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'emoji': emoji,
      'intensity': intensity,
      'intensityPercent': intensityPercent,
    };
  }
}

// ================= ASPIRATION EMOTIONS =================

class AspirationEmotion {
  final String? key;
  final String? name;
  final String? emoji;
  final String? subEmotion;
  final int? intensity;
  final int? intensityPercent;
  final String? imageUrl;

  AspirationEmotion({
    this.key,
    this.name,
    this.emoji,
    this.subEmotion,
    this.intensity,
    this.intensityPercent,
    this.imageUrl,
  });

  factory AspirationEmotion.fromJson(Map<String, dynamic> json) {
    return AspirationEmotion(
      key: json['key'],
      name: json['name'],
      emoji: json['emoji'],
      subEmotion: json['subEmotion'],
      intensity: json['intensity'],
      intensityPercent: json['intensityPercent'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'emoji': emoji,
      'subEmotion': subEmotion,
      'intensity': intensity,
      'intensityPercent': intensityPercent,
      'imageUrl': imageUrl,
    };
  }
}

// ================= ASPIRATION =================

class Aspiration {
  final String? reassessDate;

  Aspiration({this.reassessDate});

  factory Aspiration.fromJson(Map<String, dynamic> json) {
    return Aspiration(reassessDate: json['reassessDate']);
  }

  Map<String, dynamic> toJson() {
    return {'reassessDate': reassessDate};
  }
}

// ================= JOURNAL =================

class Journal {
  final String? day;
  final Forecast? forecast;
  final Reflection? reflection;

  Journal({this.day, this.forecast, this.reflection});

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      day: json['day'],
      forecast: json['forecast'] != null
          ? Forecast.fromJson(json['forecast'])
          : null,
      reflection: json['reflection'] != null
          ? Reflection.fromJson(json['reflection'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'forecast': forecast?.toJson(),
      'reflection': reflection?.toJson(),
    };
  }
}

// ================= JOURNAL EMOTION =================

class JournalEmotion {
  final String? key;
  final int? intensity;

  JournalEmotion({this.key, this.intensity});

  factory JournalEmotion.fromJson(Map<String, dynamic> json) {
    return JournalEmotion(key: json['key'], intensity: json['intensity']);
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'intensity': intensity};
  }

  /// Convenience: compute intensity as a percentage (1–5 → 20–100).
  int get intensityPercent => (intensity ?? 0) * 20;
}

// ================= FORECAST =================

class Forecast {
  final String? createdAt;
  final List<JournalEmotion>? emotions;
  final String? plan;
  final String? notes;

  Forecast({this.createdAt, this.emotions, this.plan, this.notes});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      createdAt: json['createdAt'],
      emotions: (json['emotions'] as List?)
          ?.map((e) => JournalEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      plan: json['plan'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'emotions': emotions?.map((e) => e.toJson()).toList(),
      'plan': plan,
      'notes': notes,
    };
  }
}

// ================= REFLECTION =================

class Reflection {
  final List<JournalEmotion>? emotions;
  final bool? wentAsForecast;
  final int? compareToForecast;
  final bool? planUseful;
  final String? planFeedback;
  final String? createdAt;

  Reflection({
    this.emotions,
    this.wentAsForecast,
    this.compareToForecast,
    this.planUseful,
    this.planFeedback,
    this.createdAt,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      emotions: (json['emotions'] as List?)
          ?.map((e) => JournalEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      wentAsForecast: json['wentAsForecast'],
      compareToForecast: json['compareToForecast'],
      planUseful: json['planUseful'],
      planFeedback: json['planFeedback'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotions': emotions?.map((e) => e.toJson()).toList(),
      'wentAsForecast': wentAsForecast,
      'compareToForecast': compareToForecast,
      'planUseful': planUseful,
      'planFeedback': planFeedback,
      'createdAt': createdAt,
    };
  }
}

// ================= ACTIVITY =================

class Activity {
  final String? id;
  final String? name;
  bool completed;

  Activity({this.id, this.name, this.completed = false});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      name: json['name'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'completed': completed};
  }
}

// ================= COMMUNITY =================

class Community {
  final List<dynamic>? feed;

  Community({this.feed});

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(feed: json['feed']);
  }

  Map<String, dynamic> toJson() {
    return {'feed': feed};
  }
}
