import '../constants/app_constants.dart';

class Comment {
  final int id;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final int recipeId;
  final String comment;
  final int? parentCommentId;
  final int? repliedToUserId;
  final String? repliedToUserName;
  final List<Comment> replies;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Comment({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.recipeId,
    required this.comment,
    this.parentCommentId,
    this.repliedToUserId,
    this.repliedToUserName,
    this.replies = const [],
    this.createdAt,
    this.updatedAt,
  });
  factory Comment.fromJson(Map<String, dynamic> json) {
    final avatar = json['userAvatar'];
    final name = json['userName'];
    String? fixedAvatar;
    if (avatar != null && avatar.toString().isNotEmpty) {
      final avatarStr = avatar.toString();
      fixedAvatar = _fixImageUrl(avatarStr);
    }

    return Comment(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: (name != null && name.toString().isNotEmpty)
          ? name.toString()
          : null,
      userAvatar: fixedAvatar,
      recipeId: json['recipeId'] as int,
      comment: json['comment'] as String,
      parentCommentId: json['parentCommentId'] as int?,
      repliedToUserId: json['repliedToUserId'] as int?,
      repliedToUserName: json['repliedToUserName'] as String?,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(
              json['createdAt'] as String,
            ).subtract(const Duration(hours: 7))
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(
              json['updatedAt'] as String,
            ).subtract(const Duration(hours: 7))
          : null,
    );
  }

  /// Helper để fix localhost URL - sử dụng ApiConfig.fixImageUrl()
  static String _fixImageUrl(String url) {
    return ApiConfig.fixImageUrl(url);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'recipeId': recipeId,
      'comment': comment,
      'parentCommentId': parentCommentId,
      'repliedToUserId': repliedToUserId,
      'repliedToUserName': repliedToUserName,
      'replies': replies.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Comment(id: $id, userId: $userId, comment: $comment)';
  }
}

class Rating {
  final int id;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final int recipeId;
  final int rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Rating({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.recipeId,
    required this.rating,
    this.createdAt,
    this.updatedAt,
  });
  factory Rating.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['userAvatar'] as String?;
    final fixedAvatar = rawAvatar != null && rawAvatar.isNotEmpty
        ? _fixImageUrl(rawAvatar)
        : null;
    return Rating(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String?,
      userAvatar: fixedAvatar,
      recipeId: json['recipeId'] as int,
      rating: json['rating'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(
              json['createdAt'] as String,
            ).subtract(const Duration(hours: 7))
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(
              json['updatedAt'] as String,
            ).subtract(const Duration(hours: 7))
          : null,
    );
  }

  /// Helper để fix localhost URL - sử dụng ApiConfig.fixImageUrl()
  static String _fixImageUrl(String url) {
    return ApiConfig.fixImageUrl(url);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'recipeId': recipeId,
      'rating': rating,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Rating(id: $id, userId: $userId, rating: $rating)';
  }
}

class RatingStats {
  final double averageRating;
  final int ratingsCount;
  final Map<String, int> ratingDistribution;
  RatingStats({
    required this.averageRating,
    required this.ratingsCount,
    required this.ratingDistribution,
  });
  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingsCount: json['ratingsCount'] as int,
      ratingDistribution: Map<String, int>.from(
        json['ratingDistribution'] as Map,
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'ratingDistribution': ratingDistribution,
    };
  }

  @override
  String toString() {
    return 'RatingStats(averageRating: $averageRating, ratingsCount: $ratingsCount)';
  }
}
