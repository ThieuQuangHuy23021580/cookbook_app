import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/index.dart';
import '../../models/user_model.dart';
import '../../models/recipe_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../feed/post_detail_screen.dart';
class OtherUserProfileScreen extends StatefulWidget {

  final int userId;
  const OtherUserProfileScreen({super.key, required this.userId});
  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  User? _user;
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isFollowingLoading = false;
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getUserById(widget.userId);
      if (response.success && response.data != null) {
        setState(() {
          _user = response.data;
        });
        await _loadUserRecipes();
        await _checkFollowStatus();
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkFollowStatus() async {

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;
    if (token == null) return;
    try {
      final response = await ApiService.checkIsFollowing(widget.userId, token);
      if (response.success) {
        setState(() {
          _isFollowing = response.data ?? false;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để follow'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isFollowingLoading = true);
    try {
      print('🔄 [FOLLOW] Starting follow/unfollow action for userId: ${widget.userId}');
      print('🔄 [FOLLOW] Current follow status: $_isFollowing');
      ApiResponse<String> response;
      if (_isFollowing) {
        print('🔄 [FOLLOW] Unfollowing user...');
        response = await ApiService.unfollowUser(widget.userId, token);
      } else {
        print('🔄 [FOLLOW] Following user...');
        response = await ApiService.followUser(widget.userId, token);
      }
      print('🔄 [FOLLOW] API Response - Success: ${response.success}, Message: ${response.message}');
      if (!mounted) return;
      if (response.success) {
        final wasFollowing = _isFollowing;
        final newFollowingStatus = !wasFollowing;
        print('🔄 [FOLLOW] Updating UI - Old status: $wasFollowing, New status: $newFollowingStatus');
        setState(() {
          _isFollowing = newFollowingStatus;
          if (_user != null && _user!.stats != null) {
            final oldFollowersCount = _user!.stats!.followersCount;
            final newFollowersCount = wasFollowing
                ? (oldFollowersCount > 0 ? oldFollowersCount - 1 : 0)
                : oldFollowersCount + 1;
            print('🔄 [FOLLOW] Updating followersCount - Old: $oldFollowersCount, New: $newFollowersCount');
            _user = _user!.copyWith(
              stats: UserStats(
                recipesCount: _user!.stats!.recipesCount,
                likesReceived: _user!.stats!.likesReceived,
                bookmarksReceived: _user!.stats!.bookmarksReceived,
                commentsCount: _user!.stats!.commentsCount,
                ratingsGiven: _user!.stats!.ratingsGiven,
                averageRating: _user!.stats!.averageRating,
                followersCount: newFollowersCount,
                followingCount: _user!.stats!.followingCount,
              ),
            );
          }
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newFollowingStatus ? 'Đã follow' : 'Đã unfollow'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        print('✅ [FOLLOW] Successfully ${newFollowingStatus ? "followed" : "unfollowed"} user');
      } else {
        print('❌ [FOLLOW] API returned error: ${response.message}');
        if (!mounted) return;
        String errorMessage = response.message ?? 'Có lỗi xảy ra';
        if (errorMessage.contains("doesn't exist") || errorMessage.contains("Table") || errorMessage.contains("JDBC")) {
          errorMessage = 'Lỗi kết nối database. Vui lòng liên hệ quản trị viên.';
        } else if (errorMessage.contains("Cannot follow yourself")) {
          errorMessage = 'Bạn không thể follow chính mình.';
        } else if (errorMessage.contains("Already following")) {
          errorMessage = 'Bạn đã follow người dùng này rồi.';
        } else if (errorMessage.contains("Not following")) {
          errorMessage = 'Bạn chưa follow người dùng này.';
        } else if (errorMessage.contains("User not found")) {
          errorMessage = 'Không tìm thấy người dùng.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [FOLLOW] Exception occurred: $e');
      print('❌ [FOLLOW] Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFollowingLoading = false);
      }
    }
  }

  Future<void> _loadUserRecipes() async {
    try {
      final response = await ApiService.getRecipesByUserId(widget.userId);
      if (response.success && response.data != null) {
        setState(() {
          _recipes = response.data!;
        });
      }
    } catch (e) {
      print('Error loading user recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
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
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: const Text(
                'Thông tin người dùng',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.grey[400]! : const Color(0xFFEF3A16),
                ),
              ),
            )
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy người dùng',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
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
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[200],
                                  backgroundImage: _user!.avatar != null && _user!.avatar!.isNotEmpty
                                      ? NetworkImage(ApiConfig.fixImageUrl(_user!.avatar!))
                                      : null,
                                  child: _user!.avatar == null || _user!.avatar!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _user!.fullName,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _user!.email,
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, _) {
                                    final currentUser = authProvider.currentUser;
                                    if (currentUser != null && currentUser.id == widget.userId) {
                                      return const SizedBox.shrink();
                                    }

                                    return GestureDetector(
                                      onTap: _toggleFollow,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                        decoration: BoxDecoration(
                                          gradient: _isFollowing
                                              ? LinearGradient(
                                                  colors: [
                                                    isDark ? const Color(0xFF0F0F0F) : Colors.grey[300]!,
                                                    isDark ? const Color(0xFF1A1A1A) : Colors.grey[400]!,
                                                  ],
                                                )
                                              : const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF0EA5E9),
                                                    Color(0xFF3B82F6),
                                                  ],
                                                ),
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: _isFollowing
                                                ? (isDark ? Colors.white.withOpacity(0.15) : Colors.grey[400]!)
                                                : Colors.transparent,
                                            width: isDark ? 2.0 : 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _isFollowing
                                                  ? Colors.black.withOpacity(0.2)
                                                  : const Color(0xFF0EA5E9).withOpacity(0.5),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                            if (!_isFollowing && isDark)
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.05),
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: const Offset(0, 0),
                                              ),
                                          ],
                                        ),
                                        child: _isFollowingLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    _isFollowing
                                                        ? (isDark ? Colors.white : Colors.grey[800]!)
                                                        : Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _isFollowing ? Icons.check : Icons.person_add,
                                                    size: 18,
                                                    color: _isFollowing
                                                        ? (isDark ? Colors.white : Colors.grey[800]!)
                                                        : Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _isFollowing ? 'Đã follow' : 'Follow',
                                                    style: TextStyle(
                                                      color: _isFollowing
                                                          ? (isDark ? Colors.white : Colors.grey[800]!)
                                                          : Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                                width: isDark ? 2.0 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08),
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
                            child: Builder(
                              builder: (context) {
                                final totalLikesFromRecipes = _recipes.fold<int>(
                                  0,
                                  (sum, recipe) => sum + (recipe.likesCount ?? 0),
                                );
                                final likesReceived = (_user!.likesReceived ?? 0) > 0
                                    ? _user!.likesReceived
                                    : totalLikesFromRecipes;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _StatTile(label: 'Bài đã đăng', value: '${_recipes.length}', isDark: isDark),
                                    _StatTile(label: 'Lượt thích', value: '$likesReceived', isDark: isDark),
                                    _StatTile(label: 'Người theo dõi', value: '${_user!.followersCount}', isDark: isDark),
                                  ],
                                );
                              },
                            ),
                          ),
                          if (_user!.bio != null && _user!.bio!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Giới thiệu',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _user!.bio!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                                width: isDark ? 2.0 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08),
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
                                Text(
                                  'Bài đăng công thức',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _recipes.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(40),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.restaurant_menu,
                                                size: 48,
                                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Chưa có công thức nào',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 0.8,
                                        ),
                                        itemCount: _recipes.length,
                                        itemBuilder: (context, index) {
                                          final recipe = _recipes[index];
                                          return _buildRecipeCard(recipe, isDark);
                                        },
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
  Widget _buildRecipeCard(Recipe recipe, bool isDark) {
    return GestureDetector(
      onTap: () {
        final post = Post(
          id: recipe.id.toString(),
          title: recipe.title,
          author: recipe.userName ?? 'Unknown',
          minutesAgo: recipe.createdAt != null
              ? DateTime.now().difference(recipe.createdAt!).inMinutes
              : 0,
          savedCount: recipe.bookmarksCount,
          imageUrl: recipe.imageUrl ?? '',
          ingredients: recipe.ingredients.map((ing) =>
            '${ing.name}${ing.quantity != null ? " ${ing.quantity}" : ""}${ing.unit != null ? " ${ing.unit}" : ""}'
          ).toList(),
          steps: recipe.steps.map((step) =>
            '${step.stepNumber}. ${step.title}${step.description != null ? ": ${step.description}" : ""}'
          ).toList(),
          createdAt: recipe.createdAt,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
            width: isDark ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                recipe.imageUrl ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F0F0F) : Colors.grey[200],
                    border: isDark ? Border.all(color: Colors.white.withOpacity(0.15), width: 2.0) : null,
                  ),
                  child: Icon(
                    Icons.image,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        recipe.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {

  final String label;
  final String value;
  final bool isDark;
  const _StatTile({required this.label, required this.value, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFFEF3A16).withOpacity(0.2) : const Color(0xFFEF3A16).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: isDark ? Border.all(color: Colors.white.withOpacity(0.08), width: 1.0) : null,
            boxShadow: isDark ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withOpacity(0.95) : const Color(0xFFEF3A16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
