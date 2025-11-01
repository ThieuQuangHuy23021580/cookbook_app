class Post {
  final String id;
  final String title;
  final String author;
  final int minutesAgo;
  final int savedCount;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final DateTime? createdAt;

  const Post({
    required this.id,
    required this.title,
    required this.author,
    required this.minutesAgo,
    required this.savedCount,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    this.createdAt,
  });
  
  /// Format thời gian đăng bài theo quy tắc:
  /// - Dưới 1 tiếng: phút
  /// - Dưới 1 ngày: giờ (làm tròn xuống)
  /// - Dưới 1 tuần: ngày (làm tròn xuống)
  /// - Dưới 1 tháng: tuần (làm tròn xuống)
  /// - Dưới 1 năm: tháng (làm tròn xuống)
  /// - Trên 1 năm: năm (làm tròn xuống)
  String getFormattedTime() {
    if (createdAt == null) {
      return '$minutesAgo phút trước';
    }
    
    final now = DateTime.now();
    // Giảm 14 tiếng so với thời gian thực
    final adjustedCreatedAt = createdAt!.add(const Duration(hours: 14));
    final difference = now.difference(adjustedCreatedAt);
    
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    
    if (minutes < 1) {
      // Vừa mới đăng (dưới 1 phút)
      return 'Vừa xong';
    } else if (minutes < 60) {
      // Dưới 1 tiếng
      return '$minutes phút trước';
    } else if (hours < 24) {
      // Dưới 1 ngày (làm tròn xuống)
      return '$hours giờ trước';
    } else if (days < 7) {
      // Dưới 1 tuần (hiển thị ngày)
      return '$days ngày trước';
    } else if (days < 30) {
      // Dưới 1 tháng (làm tròn xuống thành tuần)
      final weeks = days ~/ 7;
      return '$weeks tuần trước';
    } else if (days < 365) {
      // Dưới 1 năm (làm tròn xuống thành tháng)
      final months = days ~/ 30;
      return '$months tháng trước';
    } else {
      // Trên 1 năm (làm tròn xuống thành năm)
      final years = days ~/ 365;
      return '$years năm trước';
    }
  }
}


