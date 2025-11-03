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

  /// Format thời gian :
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
    final adjustedCreatedAt = createdAt!.add(const Duration(hours: 14));
    final difference = now.difference(adjustedCreatedAt);
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    if (minutes < 1) {
      return 'Vừa xong';
    } else if (minutes < 60) {
      return '$minutes phút trước';
    } else if (hours < 24) {
      return '$hours giờ trước';
    } else if (days < 7) {
      return '$days ngày trước';
    } else if (days < 30) {
      final weeks = days ~/ 7;
      return '$weeks tuần trước';
    } else if (days < 365) {
      final months = days ~/ 30;
      return '$months tháng trước';
    } else {
      final years = days ~/ 365;
      return '$years năm trước';
    }
  }
}
