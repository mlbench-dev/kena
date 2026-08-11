/// Model for user reviews API response
class UserReviewsResponse {
  final bool success;
  final String userId;
  final double averageRating;
  final int totalReviews;
  final List<VendorReview> vendors;

  UserReviewsResponse({
    required this.success,
    required this.userId,
    required this.averageRating,
    required this.totalReviews,
    required this.vendors,
  });

  factory UserReviewsResponse.fromJson(Map<String, dynamic> json) {
    return UserReviewsResponse(
      success: json['success'] ?? false,
      userId: json['user_id'] ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      vendors:
          (json['vendors'] as List<dynamic>?)
              ?.map((e) => VendorReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Model for individual vendor review in user reviews
class VendorReview {
  final String id;
  final String fullName;
  final String profileImage;
  final int rating;
  final DateTime createdAt;

  VendorReview({
    required this.id,
    required this.fullName,
    required this.profileImage,
    required this.rating,
    required this.createdAt,
  });

  factory VendorReview.fromJson(Map<String, dynamic> json) {
    return VendorReview(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      profileImage: json['profile_image'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
