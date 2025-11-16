class SearchHistory {
  final int id;
  final int userId;
  final String searchQuery;
  final DateTime searchedAt;
  SearchHistory({
    required this.id,
    required this.userId,
    required this.searchQuery,
    required this.searchedAt,
  });
  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'] as int,
      userId: json['userId'] as int,
      searchQuery: json['searchQuery'] as String,
      searchedAt: DateTime.parse(
        json['searchedAt'] as String,
      ).subtract(const Duration(hours: 7)),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'searchQuery': searchQuery,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(searchedAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${(difference.inDays / 7).floor()} tuần trước';
    }
  }

  @override
  String toString() {
    return 'SearchHistory(id: $id, query: $searchQuery, time: $searchedAt)';
  }
}

class SearchHistoryStats {
  final int totalSearches;
  final int uniqueQueries;
  final List<String> topSearches;
  SearchHistoryStats({
    required this.totalSearches,
    required this.uniqueQueries,
    required this.topSearches,
  });
  factory SearchHistoryStats.fromJson(Map<String, dynamic> json) {
    return SearchHistoryStats(
      totalSearches: json['totalSearches'] as int,
      uniqueQueries: json['uniqueQueries'] as int,
      topSearches: (json['topSearches'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }
}
