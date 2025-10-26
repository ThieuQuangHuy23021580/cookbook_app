class User {
  // Basic info
  final int id;
  final String email;
  final String fullName;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Stats (optional - null if not loaded)
  final UserStats? stats;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      stats: json['stats'] != null 
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'stats': stats?.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }

  // Convenience getters
  int get recipesCount => stats?.recipesCount ?? 0;
  int get likesReceived => stats?.likesReceived ?? 0;
  int get bookmarksReceived => stats?.bookmarksReceived ?? 0;
  int get commentsCount => stats?.commentsCount ?? 0;
  int get ratingsGiven => stats?.ratingsGiven ?? 0;
  double get averageRating => stats?.averageRating ?? 0.0;
  int get followersCount => stats?.followersCount ?? 0;
  int get followingCount => stats?.followingCount ?? 0;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserStats {
  final int recipesCount;
  final int likesReceived;
  final int bookmarksReceived;
  final int commentsCount;
  final int ratingsGiven;
  final double averageRating;
  final int followersCount;
  final int followingCount;

  UserStats({
    required this.recipesCount,
    required this.likesReceived,
    required this.bookmarksReceived,
    required this.commentsCount,
    required this.ratingsGiven,
    required this.averageRating,
    required this.followersCount,
    required this.followingCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      recipesCount: json['recipesCount'] as int? ?? 0,
      likesReceived: json['likesReceived'] as int? ?? 0,
      bookmarksReceived: json['bookmarksReceived'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      ratingsGiven: json['ratingsGiven'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipesCount': recipesCount,
      'likesReceived': likesReceived,
      'bookmarksReceived': bookmarksReceived,
      'commentsCount': commentsCount,
      'ratingsGiven': ratingsGiven,
      'averageRating': averageRating,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  @override
  String toString() {
    return 'UserStats(recipesCount: $recipesCount, likesReceived: $likesReceived)';
  }
}
