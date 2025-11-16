import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/index.dart';
import '../../constants/app_constants.dart';
import '../../models/post_model.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_history_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../services/background_fetch_service.dart';
import '../../services/api_service.dart';
import 'notifications_screen.dart';
import 'chat_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver {
  final ScrollController _recentScrollController = ScrollController();
  AdaptiveBackgroundPolling? _backgroundPolling;
  String _currentSearchQuery = '';
  Timer? _updateTimeTimer;
  String _currentTime = '';
  bool _isToolbarExpanded = false;
  static const List<String> _stopWords = [
    'món',
    'bữa',
    'ngày',
    'đơn',
    'thực',
    'các',
    'với',
    'cho',
    'của',
    'và',
    'thêm',
    'kiểu',
    'cách',
    'làm',
    'nấu',
    'chế',
    'biến',
    'theo',
    'phong',
    'cách',
    'miền',
    'kiểu',
    'đặc',
    'sản',
    'truyền',
    'thống',
    'gia',
    'đình',
    'nhà',
    'hàng',
    'quán',
    'simple',
    'easy',
  ];

  /// Phân tích recipes để lấy từ khóa thịnh hành
  List<String> _getTrendingKeywords(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      print('[TRENDING] No recipes available, using default keywords');
      return ['Thịt băm', 'Trứng', 'Cá', 'Đùi gà', 'Bánh', 'Phở'];
    }
    print(
      '[TRENDING] Analyzing ${recipes.length} recipes for trending keywords...',
    );
    Map<String, int> wordCount = {};
    for (var recipe in recipes) {
      final words = recipe.title
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^\w\s\u00C0-\u1EF9]'), '')
          .split(RegExp(r'\s+'));
      for (var word in words) {
        final cleanWord = word.trim();
        if (cleanWord.length <= 2 ||
            _stopWords.contains(cleanWord) ||
            RegExp(r'^\d+$').hasMatch(cleanWord)) {
          continue;
        }

        final capitalizedWord =
            cleanWord[0].toUpperCase() + cleanWord.substring(1);
        wordCount[capitalizedWord] = (wordCount[capitalizedWord] ?? 0) + 1;
      }
    }

    final sortedWords = wordCount.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });
    final topKeywords = sortedWords
        .where((e) => e.value >= 2)
        .take(6)
        .map((e) => e.key)
        .toList();
    if (topKeywords.length < 6) {
      final defaultKeywords = [
        'Thịt băm',
        'Trứng',
        'Cá',
        'Đùi gà',
        'Bánh',
        'Phở',
      ];
      for (var keyword in defaultKeywords) {
        if (topKeywords.length >= 6) break;
        if (!topKeywords.contains(keyword)) {
          topKeywords.add(keyword);
        }
      }
    }
    print('[TRENDING] Top keywords: $topKeywords');
    if (sortedWords.isNotEmpty) {
      print('[TRENDING] Top 10 with counts:');
      for (var entry in sortedWords.take(10)) {
        print('   - ${entry.key}: ${entry.value} times');
      }
    }
    return topKeywords;
  }

  /// Lấy hình ảnh đại diện cho từ khóa
  String? _getKeywordImage(String keyword, List<Recipe> recipes) {
    final recipe = recipes.firstWhere(
      (r) => r.title.toLowerCase().contains(keyword.toLowerCase()),
      orElse: () => recipes.isNotEmpty
          ? recipes.first
          : Recipe(id: 0, title: '', servings: 0, userId: 0, userName: ''),
    );
    final url = recipe.imageUrl;
    if (url == null || url.isEmpty) return null;
    return ApiConfig.fixImageUrl(url);
  }

  /// Preload images for trending keywords to improve performance
  Future<void> _preloadTrendingImages(
    List<String> keywords,
    List<Recipe> recipes,
  ) async {
    if (!mounted) return;
    print(
      ' [IMAGE PRELOAD] Starting to preload ${keywords.length} trending keyword images...',
    );
    final imageUrls = <String>[];
    for (var keyword in keywords) {
      final imageUrl = _getKeywordImage(keyword, recipes);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrls.add(imageUrl);
      }
    }
    print('[IMAGE PRELOAD] Found ${imageUrls.length} images to preload');
    for (var imageUrl in imageUrls) {
      if (!mounted) break;
      try {
        await precacheImage(NetworkImage(imageUrl), context);
        print('[IMAGE PRELOAD] Preloaded: $imageUrl');
      } catch (e) {
        print(' [IMAGE PRELOAD] Failed to preload $imageUrl: $e');
      }
    }
    print(' [IMAGE PRELOAD] Finished preloading trending images');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateCurrentTime();
    _updateTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCurrentTime();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRecipes();
      context.read<RecipeProvider>().loadRecentlyViewedRecipes(limit: 9);
      context.read<RecipeProvider>().loadLikedRecipeIds();
      context.read<RecipeProvider>().loadBookmarkedRecipeIds();
      context.read<SearchHistoryProvider>().loadSearchHistory(limit: 10);
      context.read<NotificationProvider>().loadUnreadCount();
      _loadBackendTrendingKeywords();
      _startBackgroundPolling();
    });
  }

  /// Cập nhật thời gian hiện tại
  void _updateCurrentTime() {
    final now = DateTime.now();
    _currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  List<String> _backendTrendingKeywords = [];
  bool _isLoadingTrending = false;
  String? _trendingError;
  Future<void> _loadBackendTrendingKeywords() async {
    print('[TRENDING] _loadBackendTrendingKeywords() called');
    if (!mounted) {
      print(' [TRENDING] Not mounted, skipping');
      return;
    }
    if (_isLoadingTrending) {
      print(' [TRENDING] Already loading, skipping');
      return;
    }
    print(' [TRENDING] Starting to load trending keywords from backend...');
    setState(() {
      _isLoadingTrending = true;
      _trendingError = null;
    });
    try {
      final token = AuthService.currentToken;
      print(
        ' [TRENDING] Token: ${token != null ? "Present (${token.substring(0, 20)}...)" : "NULL"}',
      );
      print(
        ' [TRENDING] Calling ApiService.getTrendingKeywords(days: 7, limit: 6)...',
      );
      final res = await ApiService.getTrendingKeywords(
        token: token,
        days: 7,
        limit: 6,
      );
      if (!mounted) {
        print(' [TRENDING] Not mounted after API call, skipping update');
        return;
      }
      print(
        ' [TRENDING] API Response: success=${res.success}, data=${res.data?.length ?? 0} items, message=${res.message}',
      );
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        print(
          ' [TRENDING] Successfully loaded ${res.data!.length} trending keywords: ${res.data}',
        );
        setState(() {
          _backendTrendingKeywords = res.data!;
        });
        if (mounted) {
          final recipeProvider = context.read<RecipeProvider>();
          if (recipeProvider.recipes.isEmpty) {
            await recipeProvider.loadRecipes();
          }
          _preloadTrendingImages(res.data!, recipeProvider.recipes);
        }
      } else if (!res.success) {
        print(' [TRENDING] API call failed: ${res.message}');
        setState(() {
          _trendingError = res.message;
        });
      } else {
        print(' [TRENDING] API call succeeded but no data returned');
      }
    } catch (e, stackTrace) {
      print(' [TRENDING] Exception occurred: $e');
      print(' [TRENDING] Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _trendingError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTrending = false;
        });
        print(' [TRENDING] Loading finished');
      }
    }
  }

  /// Start adaptive background polling using isolate (non-blocking)
  Future<void> _startBackgroundPolling() async {
    print(' [FEED] Starting adaptive background polling with isolate');
    _backgroundPolling = AdaptiveBackgroundPolling(
      onDataFetched: () {
        if (!mounted) return;
        _fetchDataInBackground();
      },
    );
    await _backgroundPolling!.start();
    print(' [FEED] Background polling started');
  }

  /// Fetch data in background without blocking UI
  Future<void> _fetchDataInBackground() async {
    final token = AuthService.currentToken;
    if (token == null || !mounted) return;
    print(' [FEED] Fetching data in background isolate (non-blocking)...');
    try {
      final notificationCount =
          await BackgroundFetchService.fetchNotificationCount(token: token);
      if (mounted && notificationCount != null) {
        context.read<NotificationProvider>().updateUnreadCount(
          notificationCount,
        );
        print(' [FEED] Updated notification count: $notificationCount');
      }

      final recentlyViewedData =
          await BackgroundFetchService.fetchRecentlyViewed(
            token: token,
            limit: 9,
          );
      if (mounted && recentlyViewedData != null) {
        final recipes = recentlyViewedData
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();
        context.read<RecipeProvider>().updateRecentlyViewedRecipes(recipes);
        print(' [FEED] Updated recently viewed: ${recipes.length} recipes');
      }
    } catch (e) {
      print(' [FEED] Background fetch error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundPolling?.stop();
    _updateTimeTimer?.cancel();
    _recentScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      _backgroundPolling?.markActivity();
      _fetchDataInBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SearchField(
                      hint: 'Tìm món, nguyên liệu...',
                      onSubmitted: (q) => _openSearch(q),
                      onFilterPressed: () => _showFilterBottomSheet(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          if (notificationProvider.unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  notificationProvider.unreadCount > 99
                                      ? '99+'
                                      : '${notificationProvider.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: const Color(0xFFEF3A16),
                      ),
                    ),
                    onSelected: (value) async {
                      if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserProfileScreen(),
                          ),
                        );
                      } else if (value == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      } else if (value == 'logout') {
                        final authProvider = context.read<AuthProvider>();
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                        value: 'profile',
                        child: Text('Thông tin cá nhân'),
                      ),
                      PopupMenuItem(value: 'settings', child: Text('Cài đặt')),
                      PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF000000),
                        const Color(0xFF0A0A0A),
                        const Color(0xFF0F0F0F),
                      ]
                    : [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF1F5F9),
                      ],
              ),
            ),
          ),
          ...List.generate(
            15,
            (index) => Positioned(
              top: (index * 50.0) % MediaQuery.of(context).size.height,
              left: (index * 70.0) % MediaQuery.of(context).size.width,
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
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              _sectionHeader('Từ khóa thịnh hành'),
              const SizedBox(height: 4),
              Text(
                "Cập nhật $_currentTime",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              _popularGrid(),
              const SizedBox(height: 65),
              _sectionHeader('Món bạn mới xem gần đây'),
              const SizedBox(height: 10),
              _recentHorizontal(),
              const SizedBox(height: 16),
              _buildScrollButtons(),
              const SizedBox(height: 50),
              _buildRecentSearchSection(),
              const SizedBox(height: 15),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SafeArea(
              child: Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 16, top: 16),
                child: _buildFloatingToolbar(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingToolbar(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isToolbarExpanded = !_isToolbarExpanded;
            });
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F0F0F), const Color(0xFF1A1A1A)]
                    : [Colors.white, Colors.grey[100]!],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.grey[300]!,
                width: isDark ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                if (isDark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isToolbarExpanded ? 0.125 : 0,
              child: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.grey[800],
                size: 24,
              ),
            ),
          ),
        ),
        if (_isToolbarExpanded) ...[
          const SizedBox(height: 12),
          Tooltip(
            message: 'Chat với trợ lý AI!',
            preferBelow: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            waitDuration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewPostScreen()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B35), Color(0xFFEF3A16)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF3A16).withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: const Color(0xFFEF3A16).withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildRecentSearchSection() {
    return Consumer<SearchHistoryProvider>(
      builder: (context, searchProvider, child) {
        print(' [UI] Building recent search section...');
        final searchHistory = searchProvider.searchHistory;
        final isLoading = searchProvider.isLoading;
        final error = searchProvider.error;
        print(' [UI] Search history count: ${searchHistory.length}');
        print(' [UI] Is loading: $isLoading');
        print(' [UI] Error: $error');
        print(' [UI] Search history: $searchHistory');
        Widget headerRow = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader('Tìm kiếm gần đây'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () {
                    print(' [DEBUG] Manual refresh button pressed');
                    context.read<SearchHistoryProvider>().loadSearchHistory(
                      limit: 10,
                    );
                  },
                  tooltip: 'Làm mới',
                ),
                if (searchHistory.isNotEmpty)
                  TextButton(
                    onPressed: () => _showClearHistoryConfirmation(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'Xóa tất cả',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFEF3A16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerRow,
            const SizedBox(height: 10),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFEF3A16),
                    ),
                  ),
                ),
              )
            else if (error != null && error.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        print(' [ERROR] Retry button pressed');
                        context.read<SearchHistoryProvider>().loadSearchHistory(
                          limit: 10,
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF3A16),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (searchHistory.isEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chưa có lịch sử tìm kiếm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...searchHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final keyword = entry.value;
                return _buildSearchHistoryItem(keyword, index);
              }),
          ],
        );
      },
    );
  }

  Widget _buildSearchHistoryItem(String keyword, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.15)
              : const Color(0xFFF1F5F9),
          width: isDark ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.history,
            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            size: 18,
          ),
        ),
        title: Text(
          keyword,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: isDark ? Colors.grey[400] : const Color(0xFF94A3B8),
              ),
              onPressed: () => _deleteSearchQuery(keyword),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F0F0F)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.north_east,
                size: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        onTap: () => _openSearch(keyword),
      ),
    );
  }

  Future<void> _deleteSearchQuery(String query) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa từ khóa'),
        content: Text('Bạn muốn xóa "$query" khỏi lịch sử?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF3A16),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await context.read<SearchHistoryProvider>().deleteQuery(
        query,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa "$query"'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showClearHistoryConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ lịch sử'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử tìm kiếm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF3A16),
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await context
          .read<SearchHistoryProvider>()
          .clearAllHistory();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa toàn bộ lịch sử'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _popularGrid() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final trendingKeywords = _backendTrendingKeywords;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: trendingKeywords.length,
          itemBuilder: (ctx, i) {
            final k = trendingKeywords[i];
            final keywordImage = _getKeywordImage(k, recipeProvider.recipes);
            return GestureDetector(
              onTap: () {
                _openSearch(k);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (keywordImage != null && keywordImage.isNotEmpty)
                          Image.network(
                            keywordImage,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFF6B35).withOpacity(0.8),
                                      const Color(0xFFFF8E53).withOpacity(0.6),
                                      const Color(0xFFFFB366).withOpacity(0.4),
                                    ],
                                    stops: const [0.0, 0.6, 1.0],
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8),
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFF6B35).withOpacity(0.8),
                                      const Color(0xFFFF8E53).withOpacity(0.6),
                                      const Color(0xFFFFB366).withOpacity(0.4),
                                    ],
                                    stops: const [0.0, 0.6, 1.0],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFF6B35).withOpacity(0.8),
                                  const Color(0xFFFF8E53).withOpacity(0.6),
                                  const Color(0xFFFFB366).withOpacity(0.4),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            heightFactor: 0.40,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                12,
                                12,
                                12,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                              child: Text(
                                k,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _recentHorizontal() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final recipes = recipeProvider.recentlyViewedRecipes;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        if (recipeProvider.isLoadingRecentlyViewed) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (recipes.isEmpty) {
          return SizedBox(
            height: 160,
            child: Center(
              child: Text(
                'Chưa xem công thức nào',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            controller: _recentScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () {
                final recipe = recipes[i];
                final post = Post(
                  id: recipe.id.toString(),
                  title: recipe.title,
                  author: recipe.userName ?? 'Unknown',
                  minutesAgo: recipe.createdAt != null
                      ? DateTime.now().difference(recipe.createdAt!).inMinutes
                      : 0,
                  savedCount: recipe.bookmarksCount,
                  imageUrl: recipe.imageUrl ?? '',
                  ingredients: recipe.ingredients
                      .map((ing) => '${ing.name} ${ing.quantity} ${ing.unit}')
                      .toList(),
                  steps: recipe.steps
                      .map(
                        (step) =>
                            '${step.stepNumber}. ${step.title}: ${step.description}',
                      )
                      .toList(),
                  createdAt: recipe.createdAt,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                ).then((_) {
                  if (mounted) {
                    context.read<RecipeProvider>().loadRecentlyViewedRecipes(
                      limit: 9,
                    );
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 120,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F0F0F).withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.3),
                    width: isDark ? 2.0 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    if (isDark)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        spreadRadius: 3,
                        blurRadius: 15,
                        offset: const Offset(0, 0),
                      ),
                    if (isDark)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.08),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    if (!isDark)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(-2, -2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child:
                            recipes[i].imageUrl != null &&
                                recipes[i].imageUrl!.isNotEmpty
                            ? Image.network(
                                recipes[i].imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: isDark
                                        ? const Color(0xFF0F0F0F)
                                        : const Color(0xFFF1F5F9),
                                    child: Center(
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 40,
                                        color: isDark
                                            ? Colors.grey[700]
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: isDark
                                    ? const Color(0xFF0F0F0F)
                                    : const Color(0xFFF1F5F9),
                                child: Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: isDark
                                        ? Colors.grey[700]
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '@${recipes[i].userName ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark
                                    ? Colors.grey[400]
                                    : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              recipes[i].title,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
          ),
        );
      },
    );
  }

  Widget _buildScrollButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _autoScrollRecentLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(28),
              border: isDark
                  ? Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2.0,
                    )
                  : null,
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF64748B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 8,
                        offset: const Offset(-4, -4),
                      ),
                    ],
            ),
            child: Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: isDark ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: _autoScrollRecentRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(28),
              border: isDark
                  ? Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2.0,
                    )
                  : null,
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF64748B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 8,
                        offset: const Offset(-4, -4),
                      ),
                    ],
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openSearch(String query) async {
    _currentSearchQuery = query;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(initialQuery: query),
      ),
    );
    if (mounted) {
      context.read<SearchHistoryProvider>().refreshAfterSearch();
    }
  }

  void _showFilterBottomSheet() {
    final navigatorContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialQuery: _currentSearchQuery,
        onApplyFilter: (titleQuery, includeIngredients, excludeIngredients) {
          print(' [FEED] Filter applied, navigating to SearchResultsScreen');
          print('   Title: $titleQuery');
          print('   Include: $includeIngredients');
          print('   Exclude: $excludeIngredients');
          if (!navigatorContext.mounted) return;
          Navigator.push(
            navigatorContext,
            MaterialPageRoute(
              builder: (_) => SearchResultsScreen(
                initialQuery: titleQuery ?? '',
                includeIngredients: includeIngredients,
                excludeIngredients: excludeIngredients,
              ),
            ),
          );
        },
      ),
    );
  }

  void _autoScrollRecentRight() {
    if (_recentScrollController.hasClients) {
      _recentScrollController.animateTo(
        _recentScrollController.offset + 390,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _autoScrollRecentLeft() {
    if (_recentScrollController.hasClients) {
      _recentScrollController.animateTo(
        _recentScrollController.offset - 390,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
