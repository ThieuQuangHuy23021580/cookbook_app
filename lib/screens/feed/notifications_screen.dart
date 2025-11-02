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

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  Timer? _refreshTimer;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
    
    // Auto-refresh every 3 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      if (mounted) {
        context.read<NotificationProvider>().loadNotifications();
        context.read<NotificationProvider>().loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFEF3A16).withOpacity(0.9),
                const Color(0xFFFF5A00).withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: const Text(
                'Thông báo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic background with particles
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF000000), // Pure black
                        const Color(0xFF0A0A0A), // Very dark gray
                        const Color(0xFF0F0F0F), // Slightly lighter dark gray
                      ]
                    : [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF1F5F9),
                      ],
              ),
            ),
          ),
          // Floating particles background
          ...List.generate(12, (index) => 
            Positioned(
              top: (index * 60.0) % MediaQuery.of(context).size.height,
              left: (index * 80.0) % MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 3000 + (index * 200)),
                curve: Curves.easeInOut,
                width: 6 + (index % 3) * 2,
                height: 6 + (index % 3) * 2,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFEF3A16).withOpacity(0.15)
                      : const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFEF3A16),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFFEF3A16),
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    tabs: const [
                      Tab(text: 'Tất cả'),
                      Tab(text: 'Chưa đọc'),
                    ],
                  ),
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _NotificationsTab(index: 0, scrollController: _scrollController), // Tất cả
                    _NotificationsTab(index: 1, scrollController: _scrollController), // Chưa đọc
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

/// Widget cho tab notifications
class _NotificationsTab extends StatelessWidget {
  final int index;
  final ScrollController? scrollController;
  const _NotificationsTab({required this.index, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
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

        final notifications = index == 0
            ? notificationProvider.notifications
            : notificationProvider.notifications.where((n) => !n.isRead).toList();

        return _buildNotificationsList(context, notifications, scrollController);
      },
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<AppNotification> notifications, ScrollController? scrollController) {
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
      onRefresh: () async {
        await context.read<NotificationProvider>().loadNotifications();
        context.read<NotificationProvider>().loadUnreadCount();
      },
      color: const Color(0xFFEF3A16),
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(), // Always allow scroll to enable pull-to-refresh
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => _buildNotificationItem(context, notifications[i]),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Dismissible(
        key: Key('notification_${notification.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(left: 50),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0EA5E9),
                Color(0xFF3B82F6),
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
              backgroundColor: const Color(0xFF0EA5E9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: _NotificationItemWidget(notification: notification),
      ),
    );
  }
}

/// Widget để build notification item (tách ra để tránh rebuild không cần thiết)
class _NotificationItemWidget extends StatelessWidget {
  final AppNotification notification;

  const _NotificationItemWidget({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.95) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF0EA5E9).withOpacity(0.8) 
              : const Color(0xFF0EA5E9).withOpacity(0.3),
          width: isDark ? 2.0 : 1.0,
        ),
        boxShadow: isDark ? [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ] : [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.15),
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
                if (context.mounted) Navigator.pop(context);
                
                if (recipe == null) {
                  if (context.mounted) {
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
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  ).then((_) {
                    if (!context.mounted) return;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (!context.mounted) return;
                      context.read<RecipeProvider>().loadRecentlyViewedRecipes(limit: 9);
                    });
                  });
                }
              } catch (e) {
                // Close loading dialog
                if (context.mounted) Navigator.pop(context);
                
                if (context.mounted) {
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
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0EA5E9),
                            Color(0xFF3B82F6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark 
                              ? const Color(0xFF0EA5E9).withOpacity(1.0) 
                              : const Color(0xFF0EA5E9).withOpacity(0.6),
                          width: isDark ? 2.5 : 1.5,
                        ),
                        boxShadow: isDark ? [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        ] : [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          notification.getIconEmoji(),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Text(
                            notification.message,
                            style: TextStyle(
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: isDark 
                                  ? (notification.isRead ? Colors.white.withOpacity(0.9) : Colors.white) 
                                  : const Color(0xFF1F2937),
                              height: 1.4,
                              shadows: isDark && !notification.isRead ? [
                                const Shadow(
                                  color: Color(0xFF0EA5E9),
                                  blurRadius: 8,
                                  offset: Offset(0, 0),
                                ),
                              ] : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      // Time with icon
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (!notification.isRead)
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0EA5E9),
                              Color(0xFF3B82F6),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: isDark ? [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ] : [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
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


