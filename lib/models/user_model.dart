class User {
  // Basic info
  final int id;
  final String email;
  final String fullName;
  final String? avatar;
  final String? bio;
  final String? hometown;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Stats (optional - null if not loaded)
  final UserStats? stats;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    this.bio,
    this.hometown,
    this.createdAt,
    this.updatedAt,
    this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Import ApiConfig để dùng fixImageUrl
    // Đảm bảo import '../constants/app_constants.dart' ở đầu file
    final rawAvatar = json['avatar'] as String? ?? json['avatarUrl'] as String?;
    final fixedAvatar = rawAvatar != null && rawAvatar.isNotEmpty 
        ? _fixImageUrl(rawAvatar) 
        : null;
    
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatar: fixedAvatar,
      bio: json['bio'] as String?,
      hometown: json['hometown'] as String?,
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
  
  /// Helper để fix localhost URL
  static String _fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    // Nếu URL đã đúng (không chứa localhost), return luôn
    if (!url.contains('localhost') && !url.contains('127.0.0.1')) {
      return url;
    }
    
    print('⚠️ [USER MODEL] Detected localhost URL: $url');
    
    // Replace localhost:8080 với ngrok domain
    // Giả sử backend URL là: https://gearldine-subventral-overcuriously.ngrok-free.dev
    const ngrokDomain = 'https://gearldine-subventral-overcuriously.ngrok-free.dev';
    
    // Extract path từ localhost URL
    final uri = Uri.parse(url);
    final path = uri.path; // /uploads/avatars/xxx.jpg
    
    final fixedUrl = '$ngrokDomain$path';
    print('✅ [USER MODEL] Fixed URL: $fixedUrl');
    
    return fixedUrl;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'bio': bio,
      'hometown': hometown,
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
    String? bio,
    String? hometown,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      hometown: hometown ?? this.hometown,
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
