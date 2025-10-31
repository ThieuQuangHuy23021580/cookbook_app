import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await NotificationRepository.getNotifications();
      if (response.success) {
        _notifications = response.data ?? [];
        _updateUnreadCount();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Lỗi tải thông báo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final response = await NotificationRepository.getUnreadCount();
      if (response.success) {
        _unreadCount = response.data ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error loading unread count: $e');
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await NotificationRepository.markAsRead(notificationId);
      if (response.success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Create new notification with isRead = true
          final updatedNotification = AppNotification(
            id: _notifications[index].id,
            userId: _notifications[index].userId,
            type: _notifications[index].type,
            actorId: _notifications[index].actorId,
            actorName: _notifications[index].actorName,
            actorAvatar: _notifications[index].actorAvatar,
            recipeId: _notifications[index].recipeId,
            recipeTitle: _notifications[index].recipeTitle,
            recipeImage: _notifications[index].recipeImage,
            commentId: _notifications[index].commentId,
            message: _notifications[index].message,
            isRead: true,
            createdAt: _notifications[index].createdAt,
          );
          _notifications[index] = updatedNotification;
          _updateUnreadCount();
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await NotificationRepository.deleteNotification(notificationId);
      if (response.success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        _updateUnreadCount();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Update unread count from current notifications
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  /// Update unread count directly (for background updates)
  void updateUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

