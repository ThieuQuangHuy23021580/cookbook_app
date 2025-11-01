import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/index.dart';
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
  // ScrollController cho danh sách món gần đây
  final ScrollController _recentScrollController = ScrollController();
  AdaptiveBackgroundPolling? _backgroundPolling;
  
  // Search state
  String _currentSearchQuery = '';
  
  // Thời gian cập nhật thực tế
  Timer? _updateTimeTimer;
  String _currentTime = '';

  // Danh sách từ dừng (stop words) để loại bỏ khi phân tích
  static const List<String> _stopWords = [
    'món', 'bữa', 'ngày', 'đơn', 'thực', 'các', 'với', 'cho',
    'của', 'và', 'thêm', 'kiểu', 'cách', 'làm', 'nấu', 'chế', 'biến',
    'theo', 'phong', 'cách', 'miền', 'kiểu', 'đặc', 'sản', 'truyền',
    'thống', 'gia', 'đình', 'nhà', 'hàng', 'quán', 'simple', 'easy',
  ];

  /// Phân tích recipes để lấy từ khóa thịnh hành
  List<String> _getTrendingKeywords(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      print('⚠️ [TRENDING] No recipes available, using default keywords');
      return ['Thịt băm', 'Trứng', 'Cá', 'Đùi gà', 'Bánh', 'Phở'];
    }

    print('📊 [TRENDING] Analyzing ${recipes.length} recipes for trending keywords...');
    
    // Map để đếm số lần xuất hiện của mỗi từ
    Map<String, int> wordCount = {};

    for (var recipe in recipes) {
      // Tách title thành các từ
      final words = recipe.title
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^\w\s\u00C0-\u1EF9]'), '') // Loại bỏ ký tự đặc biệt, giữ tiếng Việt
          .split(RegExp(r'\s+'));

      for (var word in words) {
        final cleanWord = word.trim();
        
        // Bỏ qua từ quá ngắn, từ dừng, và số
        if (cleanWord.length <= 2 || 
            _stopWords.contains(cleanWord) ||
            RegExp(r'^\d+$').hasMatch(cleanWord)) {
          continue;
        }

        // Capitalize first letter
        final capitalizedWord = cleanWord[0].toUpperCase() + cleanWord.substring(1);
        wordCount[capitalizedWord] = (wordCount[capitalizedWord] ?? 0) + 1;
      }
    }

    // Sắp xếp theo số lần xuất hiện giảm dần và lấy top 6
    final sortedWords = wordCount.entries.toList()
      ..sort((a, b) {
        // Ưu tiên từ xuất hiện nhiều hơn
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        // Nếu bằng nhau thì sắp xếp theo alphabet
        return a.key.compareTo(b.key);
      });

    // Lấy top 6 từ khóa, đảm bảo có ít nhất 2 lần xuất hiện
    final topKeywords = sortedWords
        .where((e) => e.value >= 2)
        .take(6)
        .map((e) => e.key)
        .toList();

    // Nếu không đủ 6 từ khóa, thêm từ default
    if (topKeywords.length < 6) {
      final defaultKeywords = ['Thịt băm', 'Trứng', 'Cá', 'Đùi gà', 'Bánh', 'Phở'];
      for (var keyword in defaultKeywords) {
        if (topKeywords.length >= 6) break;
        if (!topKeywords.contains(keyword)) {
          topKeywords.add(keyword);
        }
      }
    }

    print('✅ [TRENDING] Top keywords: $topKeywords');
    if (sortedWords.isNotEmpty) {
      print('📈 [TRENDING] Top 10 with counts:');
      for (var entry in sortedWords.take(10)) {
        print('   - ${entry.key}: ${entry.value} times');
      }
    }

    return topKeywords;
  }

  /// Lấy hình ảnh đại diện cho từ khóa
  String? _getKeywordImage(String keyword, List<Recipe> recipes) {
    // Tìm recipe đầu tiên có chứa keyword trong title
    final recipe = recipes.firstWhere(
      (r) => r.title.toLowerCase().contains(keyword.toLowerCase()),
      orElse: () => recipes.isNotEmpty ? recipes.first : Recipe(
        id: 0,
        title: '',
        servings: 0,
        userId: 0,
        userName: '',
      ),
    );
    
    return recipe.imageUrl;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Khởi tạo thời gian ngay lập tức
    _updateCurrentTime();
    
    // Cập nhật thời gian mỗi phút
    _updateTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCurrentTime();
        });
      }
    });
    
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRecipes();
      context.read<RecipeProvider>().loadRecentlyViewedRecipes(limit: 9);
      context.read<RecipeProvider>().loadLikedRecipeIds();
      context.read<RecipeProvider>().loadBookmarkedRecipeIds();
      context.read<SearchHistoryProvider>().loadSearchHistory(limit: 10);
      context.read<NotificationProvider>().loadUnreadCount();
      // Fetch backend trending keywords (non-blocking). Fallback to local logic in UI
      _loadBackendTrendingKeywords();
      
      // Start adaptive background polling with isolate
      _startBackgroundPolling();
    });
  }
  
  /// Cập nhật thời gian hiện tại
  void _updateCurrentTime() {
    final now = DateTime.now();
    _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  List<String> _backendTrendingKeywords = [];
  bool _isLoadingTrending = false;
  String? _trendingError;

  Future<void> _loadBackendTrendingKeywords() async {
    print('🔍 [TRENDING] _loadBackendTrendingKeywords() called');
    if (!mounted) {
      print('⚠️ [TRENDING] Not mounted, skipping');
      return;
    }
    if (_isLoadingTrending) {
      print('⚠️ [TRENDING] Already loading, skipping');
      return;
    }
    
    print('✅ [TRENDING] Starting to load trending keywords from backend...');
    setState(() { _isLoadingTrending = true; _trendingError = null; });
    
    try {
      final token = AuthService.currentToken;
      print('🔑 [TRENDING] Token: ${token != null ? "Present (${token.substring(0, 20)}...)" : "NULL"}');
      
      print('📤 [TRENDING] Calling ApiService.getTrendingKeywords(days: 7, limit: 6)...');
      final res = await ApiService.getTrendingKeywords(token: token, days: 7, limit: 6);
      
      if (!mounted) {
        print('⚠️ [TRENDING] Not mounted after API call, skipping update');
        return;
      }
      
      print('📥 [TRENDING] API Response: success=${res.success}, data=${res.data?.length ?? 0} items, message=${res.message}');
      
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        print('✅ [TRENDING] Successfully loaded ${res.data!.length} trending keywords: ${res.data}');
        setState(() { _backendTrendingKeywords = res.data!; });
      } else if (!res.success) {
        print('❌ [TRENDING] API call failed: ${res.message}');
        setState(() { _trendingError = res.message; });
      } else {
        print('⚠️ [TRENDING] API call succeeded but no data returned');
      }
    } catch (e, stackTrace) {
      print('❌ [TRENDING] Exception occurred: $e');
      print('❌ [TRENDING] Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() { _trendingError = e.toString(); });
    } finally {
      if (mounted) {
        setState(() { _isLoadingTrending = false; });
        print('🏁 [TRENDING] Loading finished');
      }
    }
  }
  
  /// Start adaptive background polling using isolate (non-blocking)
  Future<void> _startBackgroundPolling() async {
    print('🚀 [FEED] Starting adaptive background polling with isolate');
    
    _backgroundPolling = AdaptiveBackgroundPolling(
      onDataFetched: () {
        if (!mounted) return;
        
        // Fetch data in background isolate (won't block UI)
        _fetchDataInBackground();
      },
    );
    
    await _backgroundPolling!.start();
    print('✅ [FEED] Background polling started');
  }
  
  /// Fetch data in background without blocking UI
  Future<void> _fetchDataInBackground() async {
    final token = AuthService.currentToken;
    if (token == null || !mounted) return;
    
    print('🔒 [FEED] Fetching data in background isolate (non-blocking)...');
    
    // Fetch in background isolate - won't block UI
    try {
      // Fetch notification count
      final notificationCount = await BackgroundFetchService.fetchNotificationCount(
        token: token,
      );
      
      if (mounted && notificationCount != null) {
        context.read<NotificationProvider>().updateUnreadCount(notificationCount);
        print('✅ [FEED] Updated notification count: $notificationCount');
      }
      
      // Fetch recently viewed recipes
      final recentlyViewedData = await BackgroundFetchService.fetchRecentlyViewed(
        token: token,
        limit: 9,
      );
      
      if (mounted && recentlyViewedData != null) {
        // Parse and update recipes
        final recipes = recentlyViewedData
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();
        context.read<RecipeProvider>().updateRecentlyViewedRecipes(recipes);
        print('✅ [FEED] Updated recently viewed: ${recipes.length} recipes');
      }
    } catch (e) {
      print('❌ [FEED] Background fetch error: $e');
      // Don't show error to user, just log it
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
    // Mark activity and refresh when app comes to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      _backgroundPolling?.markActivity();
      _fetchDataInBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to prevent status bar issues
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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
                  icon: const CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.person, size: 18, color: Color(0xFFEF3A16))),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
                    } else if (value == 'settings') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    } else if (value == 'logout') {
                      // Handle logout
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.logout();
                      
                      if (context.mounted) {
                        // Navigate to login screen
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    }
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'profile', child: Text('Thông tin cá nhân')),
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
          // Dynamic background with particles
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFAFAFA),
                  const Color(0xFFF8FAFC),
                  const Color(0xFFF1F5F9),
                ],
              ),
            ),
          ),
          // Floating particles background
          ...List.generate(15, (index) => 
            Positioned(
              top: (index * 50.0) % MediaQuery.of(context).size.height,
              left: (index * 70.0) % MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 3000 + (index * 200)),
                curve: Curves.easeInOut,
                width: 6 + (index % 3) * 2,
                height: 6 + (index % 3) * 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
          const SizedBox(height: 10),
          _sectionHeader('Từ khóa thịnh hành'),
          const SizedBox(height: 4),
          Text(
            "Cập nhật $_currentTime",
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
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
          // Nút lướt bên dưới danh sách
          _buildScrollButtons(),
          const SizedBox(height: 50),
          _buildRecentSearchSection(),
          const SizedBox(height: 15),
            ],
          ),
          // Chat bubble button - positioned at bottom left, same height as FAB
          Positioned(
            left: 16,
            bottom: 16,
            child: SafeArea(
              child: Tooltip(
                message: 'Chat với trợ lý AI!',
                preferBelow: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0EA5E9),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                waitDuration: const Duration(milliseconds: 500),
                showDuration: const Duration(seconds: 2),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0EA5E9), // Sky blue - sáng
                          Color(0xFF3B82F6), // Blue-500 - sáng
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      //Floating-UpPost Button - 3D Effect
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Outer glow
            BoxShadow(
              color: const Color(0xFFEF3A16).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            // 3D shadow
            BoxShadow(
              color: const Color(0xFFEF3A16).withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            // Inner highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFEF3A16),
          elevation: 0,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPostScreen()));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF6B35),
                  const Color(0xFFEF3A16),
                ],
              ),
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
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title, 
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  // Build Recent Search Section from API
  Widget _buildRecentSearchSection() {
    return Consumer<SearchHistoryProvider>(
      builder: (context, searchProvider, child) {
        print('🎨 [UI] Building recent search section...');
        final searchHistory = searchProvider.searchHistory;
        final isLoading = searchProvider.isLoading;
        final error = searchProvider.error;
        
        print('🎨 [UI] Search history count: ${searchHistory.length}');
        print('🎨 [UI] Is loading: $isLoading');
        print('🎨 [UI] Error: $error');
        print('🎨 [UI] Search history: $searchHistory');

        // Section header with clear all button
        Widget headerRow = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader('Tìm kiếm gần đây'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Debug refresh button
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF64748B)),
                  onPressed: () {
                    print('🔄 [DEBUG] Manual refresh button pressed');
                    context.read<SearchHistoryProvider>().loadSearchHistory(limit: 10);
                  },
                  tooltip: 'Làm mới',
                ),
                if (searchHistory.isNotEmpty)
                  TextButton(
                    onPressed: () => _showClearHistoryConfirmation(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            
            // Loading state
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF3A16)),
                  ),
                ),
              )
            
            // Error state
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
                        print('🔄 [ERROR] Retry button pressed');
                        context.read<SearchHistoryProvider>().loadSearchHistory(limit: 10);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF3A16),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              )
            
            // Empty state
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
            
            // Search history list
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

  // Build individual search history item
  Widget _buildSearchHistoryItem(String keyword, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.history, color: Color(0xFF64748B), size: 18),
        ),
        title: Text(
          keyword,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete button
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
              onPressed: () => _deleteSearchQuery(keyword),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            // Search again button
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.north_east, size: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
        onTap: () => _openSearch(keyword),
      ),
    );
  }

  // Delete a specific search query
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
      final success = await context.read<SearchHistoryProvider>().deleteQuery(query);
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

  // Show confirmation dialog for clearing all history
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
      final success = await context.read<SearchHistoryProvider>().clearAllHistory();
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
        // Tạm thời chỉ dùng dữ liệu backend; không dùng fallback local
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
                        // Background image or gradient fallback
                        if (keywordImage != null && keywordImage.isNotEmpty)
                          Image.network(
                            keywordImage,
                            fit: BoxFit.cover,
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
                        // Dark overlay for better text visibility
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
                        // Bottom overlay gradient covering a portion of the tile (not only behind the text)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            heightFactor: 0.40,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
        
        if (recipeProvider.isLoadingRecentlyViewed) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (recipes.isEmpty) {
          return const SizedBox(
            height: 160,
            child: Center(
              child: Text(
                'Chưa xem công thức nào',
                style: TextStyle(color: Colors.grey),
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
                  ingredients: recipe.ingredients.map((ing) => '${ing.name} ${ing.quantity} ${ing.unit}').toList(),
                  steps: recipe.steps.map((step) => '${step.stepNumber}. ${step.title}: ${step.description}').toList(),
                  createdAt: recipe.createdAt,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                ).then((_) {
                  // Reload recently viewed when user comes back
                  if (mounted) {
                    context.read<RecipeProvider>().loadRecentlyViewedRecipes(limit: 9);
                  }
                });
              },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
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
                // Phần hình ảnh (6/10)
                Expanded(
                  flex: 6,
                    child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: recipes[i].imageUrl != null && recipes[i].imageUrl!.isNotEmpty
                        ? Image.network(
                            recipes[i].imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                  ),
                ),
                // Phần thông tin (4/10)
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Tên người đăng
                        Text(
                          '@${recipes[i].userName ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Tên món ăn
                        Text(
                          recipes[i].title,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF1F2937),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nút lướt sang trái - Neumorphism Design
        GestureDetector(
          onTap: _autoScrollRecentLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                // Outer shadow (dark)
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
                // Inner shadow (light)
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 8,
                  offset: const Offset(-4, -4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Color(0xFF475569),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Nút lướt sang phải - Neumorphism Design
        GestureDetector(
          onTap: _autoScrollRecentRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                // Outer shadow (dark)
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
                // Inner shadow (light)
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 8,
                  offset: const Offset(-4, -4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF475569),
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
    
    // Refresh search history when coming back (backend auto-saves during search)
    if (mounted) {
      context.read<SearchHistoryProvider>().refreshAfterSearch();
    }
  }

  void _showFilterBottomSheet() {
    // Save context before showing bottom sheet
    final navigatorContext = context;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialQuery: _currentSearchQuery,
        onApplyFilter: (titleQuery, includeIngredients, excludeIngredients) {
          print('🚀 [FEED] Filter applied, navigating to SearchResultsScreen');
          print('   Title: $titleQuery');
          print('   Include: $includeIngredients');
          print('   Exclude: $excludeIngredients');
          
          // Navigate to search results with filters using saved context
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

  // Method để tự động lướt danh sách món gần đây sang phải
  void _autoScrollRecentRight() {
    if (_recentScrollController.hasClients) {
      _recentScrollController.animateTo(
        _recentScrollController.offset + 390, // Lướt một khoảng bằng chiều rộng 1 item + margin
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method để tự động lướt danh sách món gần đây sang trái
  void _autoScrollRecentLeft() {
    if (_recentScrollController.hasClients) {
      _recentScrollController.animateTo(
        _recentScrollController.offset - 390, // Lướt ngược lại
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}


