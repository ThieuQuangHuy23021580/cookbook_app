import '../models/api_response_model.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class NotificationRepository {
  /// Get all notifications
  static Future<ApiResponse<List<AppNotification>>> getNotifications() async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error('Vui lòng đăng nhập');
    }
    return await ApiService.getNotifications(token);
  }

  /// Get unread notifications
  static Future<ApiResponse<List<AppNotification>>> getUnreadNotifications() async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error('Vui lòng đăng nhập');
    }
    return await ApiService.getUnreadNotifications(token);
  }

  /// Get unread notification count
  static Future<ApiResponse<int>> getUnreadNotificationCount() async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error('Vui lòng đăng nhập');
    }
    return await ApiService.getUnreadNotificationCount(token);
  }
  
  // Alias for backward compatibility
  static Future<ApiResponse<int>> getUnreadCount() async {
    return getUnreadNotificationCount();
  }

  /// Mark notification as read
  static Future<ApiResponse<String>> markAsRead(int notificationId) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error('Vui lòng đăng nhập');
    }
    return await ApiService.markNotificationAsRead(notificationId, token);
  }

  /// Delete notification
  static Future<ApiResponse<String>> deleteNotification(int notificationId) async {
    final token = AuthService.currentToken;
    if (token == null) {
      return ApiResponse.error('Vui lòng đăng nhập');
    }
    return await ApiService.deleteNotification(notificationId, token);
  }
}

