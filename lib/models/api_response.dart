
import 'comment_rating_model.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message)';
  }
}

// Models cho Like Response
class LikeResponse {
  final String message;
  final bool liked;
  final int likesCount;

  LikeResponse({
    required this.message,
    required this.liked,
    required this.likesCount,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
      message: json['message'] as String,
      liked: json['liked'] as bool,
      likesCount: json['likesCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'liked': liked,
      'likesCount': likesCount,
    };
  }
}

// Models cho Bookmark Response
class BookmarkResponse {
  final String message;
  final bool bookmarked;
  final int bookmarksCount;

  BookmarkResponse({
    required this.message,
    required this.bookmarked,
    required this.bookmarksCount,
  });

  factory BookmarkResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkResponse(
      message: json['message'] as String,
      bookmarked: json['bookmarked'] as bool,
      bookmarksCount: json['bookmarksCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'bookmarked': bookmarked,
      'bookmarksCount': bookmarksCount,
    };
  }
}

// Models cho Rating Response
class RatingResponse {
  final Rating rating;
  final double averageRating;
  final int ratingsCount;
  final String message;

  RatingResponse({
    required this.rating,
    required this.averageRating,
    required this.ratingsCount,
    required this.message,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>),
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingsCount: json['ratingsCount'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating.toJson(),
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'message': message,
    };
  }
}
