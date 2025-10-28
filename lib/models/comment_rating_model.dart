class Comment {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final int recipeId;
  final String comment;
  final int? parentCommentId;
  final int? repliedToUserId; // ID của user mà comment này đang reply
  final String? repliedToUserName; // Username của user mà comment này đang reply
  final List<Comment> replies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
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
    
    // Fix localhost URL for avatar
    String? fixedAvatar;
    if (avatar != null && avatar.toString().isNotEmpty) {
      final avatarStr = avatar.toString();
      fixedAvatar = _fixImageUrl(avatarStr);
    }
    
    return Comment(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: (name != null && name.toString().isNotEmpty) ? name.toString() : 'Anonymous',
      userAvatar: fixedAvatar,
      recipeId: json['recipeId'] as int,
      comment: json['comment'] as String,
      parentCommentId: json['parentCommentId'] as int?,
      repliedToUserId: json['repliedToUserId'] as int?,
      repliedToUserName: json['repliedToUserName'] as String?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }
  
  /// Helper để fix localhost URL
  static String _fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    // Nếu URL đã đúng (không chứa localhost), return luôn
    if (!url.contains('localhost') && !url.contains('127.0.0.1')) {
      return url;
    }
    
    print('⚠️ [COMMENT MODEL] Detected localhost URL: $url');
    
    // Replace localhost:8080 với ngrok domain
    const ngrokDomain = 'https://gearldine-subventral-overcuriously.ngrok-free.dev';
    
    // Extract path từ localhost URL
    final uri = Uri.parse(url);
    final path = uri.path; // /uploads/avatars/xxx.jpg
    
    final fixedUrl = '$ngrokDomain$path';
    print('✅ [COMMENT MODEL] Fixed URL: $fixedUrl');
    
    return fixedUrl;
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
  final String userName;
  final String? userAvatar;
  final int recipeId;
  final int rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.recipeId,
    required this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    // Fix localhost URL for avatar
    final rawAvatar = json['userAvatar'] as String?;
    final fixedAvatar = rawAvatar != null && rawAvatar.isNotEmpty 
        ? _fixImageUrl(rawAvatar) 
        : null;
    
    return Rating(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userAvatar: fixedAvatar,
      recipeId: json['recipeId'] as int,
      rating: json['rating'] as int,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }
  
  /// Helper để fix localhost URL
  static String _fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    // Nếu URL đã đúng (không chứa localhost), return luôn
    if (!url.contains('localhost') && !url.contains('127.0.0.1')) {
      return url;
    }
    
    print('⚠️ [RATING MODEL] Detected localhost URL: $url');
    
    // Replace localhost:8080 với ngrok domain
    const ngrokDomain = 'https://gearldine-subventral-overcuriously.ngrok-free.dev';
    
    // Extract path từ localhost URL
    final uri = Uri.parse(url);
    final path = uri.path; // /uploads/avatars/xxx.jpg
    
    final fixedUrl = '$ngrokDomain$path';
    print('✅ [RATING MODEL] Fixed URL: $fixedUrl');
    
    return fixedUrl;
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
      ratingDistribution: Map<String, int>.from(json['ratingDistribution'] as Map),
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
