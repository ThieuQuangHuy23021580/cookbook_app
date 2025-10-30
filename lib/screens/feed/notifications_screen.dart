import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification_model.dart';
import '../../models/post_model.dart';
import 'post_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
    
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<NotificationProvider>().loadNotifications();
        context.read<NotificationProvider>().loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFEF3A16).withOpacity(0.9),
                const Color(0xFFFF5A00).withOpacity(0.8),
              ],
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFE4E6),
              const Color(0xFFFFF5F7),
              Colors.white,
            ],
            stops: const [0.0, 0.15, 0.4],
          ),
        ),
        child: SafeArea(
          child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFEF3A16),
                ),
              );
            }

          if (notificationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    notificationProvider.error!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      notificationProvider.loadNotifications();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF3A16),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => notificationProvider.loadNotifications(),
            color: const Color(0xFFEF3A16),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _buildNotificationItem(notifications[i]),
            ),
          );
        },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Dismissible(
        key: Key('notification_${notification.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(left: 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF1493).withOpacity(0.7),
                const Color(0xFFFF69B4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (direction) {
          context.read<NotificationProvider>().deleteNotification(notification.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Đã xóa thông báo'),
                ],
              ),
              backgroundColor: const Color(0xFFFF69B4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFFFFAFB),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB6C1).withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Mark as read
          if (!notification.isRead) {
            context.read<NotificationProvider>().markAsRead(notification.id);
          }

          // Navigate to recipe detail if available
          if (notification.recipeId != null) {
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFEF3A16),
                ),
              ),
            );

            try {
              // Fetch full recipe detail
              final recipeProvider = context.read<RecipeProvider>();
              final authProvider = context.read<AuthProvider>();
              
              final recipe = await recipeProvider.getRecipeById(notification.recipeId!);
              
              // Close loading dialog
              if (mounted) Navigator.pop(context);
              
              if (recipe == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không thể tải bài viết'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // Map ingredients with detailed logging
              final ingredientsList = <String>[];
              for (var ing in recipe.ingredients) {
                final text = '${ing.name}${ing.quantity != null ? " ${ing.quantity}" : ""}${ing.unit != null ? " ${ing.unit}" : ""}';
                ingredientsList.add(text);
              }
              
              // Map steps with detailed logging
              final stepsList = <String>[];
              for (var step in recipe.steps) {
                final text = '${step.stepNumber}. ${step.title}';
                stepsList.add(text);
              }
              
              // Create full Post object
              final post = Post(
                id: recipe.id.toString(),
                title: recipe.title,
                author: recipe.userName ?? authProvider.currentUser?.fullName ?? 'Unknown',
                minutesAgo: recipe.createdAt != null 
                    ? DateTime.now().difference(recipe.createdAt!).inMinutes
                    : 0,
                savedCount: recipe.bookmarksCount,
                imageUrl: recipe.imageUrl ?? '',
                ingredients: ingredientsList,
                steps: stepsList,
                createdAt: recipe.createdAt ?? DateTime.now(),
              );
              
              // Navigate to post detail screen
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post: post),
                  ),
                );
              }
            } catch (e) {
              // Close loading dialog
              if (mounted) Navigator.pop(context);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with gradient background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFB6C1).withOpacity(0.25),
                            const Color(0xFFFFE4E6).withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFB6C1).withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          notification.getIconEmoji(),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Message
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF1F2937),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Time with icon
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Unread indicator
                    if (!notification.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF69B4),
                              Color(0xFFFFB6C1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF69B4).withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7} tuần trước';
    } else if (difference.inDays < 365) {
      return '${difference.inDays ~/ 30} tháng trước';
    } else {
      return '${difference.inDays ~/ 365} năm trước';
    }
  }
}


