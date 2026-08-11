class ForecastNotes {
  final bool? success;
  final String? message;
  final List<ForecastNotesDay> data;

  ForecastNotes({this.success, this.message, this.data = const []});

  factory ForecastNotes.fromJson(Map<String, dynamic> json) {
    return ForecastNotes(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data:
          (json['data'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ForecastNotesDay.fromJson)
              .toList() ??
          const [],
    );
  }
}

class ForecastNotesDay {
  final String? day;
  final List<ForecastNote> notes;

  ForecastNotesDay({this.day, this.notes = const []});

  factory ForecastNotesDay.fromJson(Map<String, dynamic> json) {
    return ForecastNotesDay(
      day: json['day'] as String?,
      notes:
          (json['notes'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ForecastNote.fromJson)
              .toList() ??
          const [],
    );
  }
}

class ForecastNote {
  final String? id;
  final String? content;
  final String? createdAt;
  final bool isPrivate;
  final bool isAspire;
  final int likes;
  final int comments;

  ForecastNote({
    this.id,
    this.content,
    this.createdAt,
    this.isPrivate = false,
    this.isAspire = false,
    this.likes = 0,
    this.comments = 0,
  });

  factory ForecastNote.fromJson(Map<String, dynamic> json) {
    return ForecastNote(
      id: json['id']?.toString(),
      content: json['content']?.toString(),
      createdAt: json['createdAt']?.toString(),
      isPrivate: json['isPrivate'] == true,
      isAspire: json['isAspire'] == true,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
    );
  }
}
