import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/recipe_model.dart';
import '../../models/recipe_components.dart';
import '../../models/comment_rating_model.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/recipe_repository.dart';
import '../../constants/app_constants.dart';
import '../profile/other_user_profile_screen.dart';
import '../profile/user_profile_screen.dart';
class PostDetailScreen extends StatefulWidget {

  final Post post;
  const PostDetailScreen({super.key, required this.post});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isBookmarked = false;
  bool _isBookmarking = false;
  bool _isLiked = false;
  bool _isLiking = false;
  int _likesCount = 0;
  bool _isLoadingRecipe = false;
  Recipe? _recipeDetail;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final Map<int, bool> _expandedReplies = {};
  @override
  void initState() {
    super.initState();
    print(' [POST DETAIL] Initializing PostDetailScreen for post ID: ${widget.post.id}');
    print(' [POST DETAIL] Initial likesCount from Post object: ${widget.post.savedCount} (this is savedCount, not likesCount)');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final recipeId = int.tryParse(widget.post.id);
      if (recipeId != null) {
        print(' [POST DETAIL] Starting data loading for recipe ID: $recipeId');
        context.read<CommentProvider>().loadComments(recipeId);
        context.read<RatingProvider>().loadAllRatingData(recipeId);
        _loadBookmarkStatus();
        _loadLikeStatus();
        print(' [POST DETAIL] Loading recipe detail (will update likesCount from API)...');
        await _loadRecipeDetail(recipeId);
        print(' [POST DETAIL] Data loading completed. Final likesCount: $_likesCount');
      } else {
        print(' [POST DETAIL] Invalid recipe ID: ${widget.post.id}');
      }
    });
  }

  Future<void> _loadRecipeDetail(int recipeId) async {
    print(' [RECIPE DETAIL] Loading recipe detail for ID: $recipeId');
    setState(() {
      _isLoadingRecipe = true;
    });
    try {
      final recipeProvider = context.read<RecipeProvider>();
      final recipe = await recipeProvider.getRecipeById(recipeId);
      if (mounted) {
        setState(() {
          _recipeDetail = recipe;
          if (recipe != null) {
            final oldLikesCount = _likesCount;
            _likesCount = recipe.likesCount;
            print(' [RECIPE DETAIL] Updated likesCount: $oldLikesCount → $_likesCount (from API)');
            print(' [RECIPE DETAIL] Recipe data - likesCount: ${recipe.likesCount}, bookmarksCount: ${recipe.bookmarksCount}, ratingsCount: ${recipe.ratingsCount}');
          } else {
            print(' [RECIPE DETAIL] Recipe detail is null, likesCount remains: $_likesCount');
          }
          _isLoadingRecipe = false;
        });
      }
    } catch (e, stackTrace) {
      print(' [RECIPE DETAIL] Error loading recipe detail: $e');
      print(' [RECIPE DETAIL] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingRecipe = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarkStatus() async {

    final recipeId = int.tryParse(widget.post.id);
    if (recipeId == null) return;
    final recipeProvider = context.read<RecipeProvider>();
    _isBookmarked = recipeProvider.bookmarkedRecipeIds.contains(recipeId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadLikeStatus() async {

    final recipeId = int.tryParse(widget.post.id);
    if (recipeId == null) {
      print(' [LIKE STATUS] Invalid recipe ID: ${widget.post.id}');
      return;
    }
    print(' [LIKE STATUS] Loading like status for recipe $recipeId');
    final recipeProvider = context.read<RecipeProvider>();
    _isLiked = recipeProvider.likedRecipeIds.contains(recipeId);
    print(' [LIKE STATUS] Is liked: $_isLiked');
    try {
      try {
        final recipe = recipeProvider.recipes.firstWhere((r) => r.id == recipeId);
        _likesCount = recipe.likesCount;
        print(' [LIKE STATUS] Found in recipes list, likesCount: $_likesCount');
      } catch (e) {
        try {
          final recipe = recipeProvider.searchResults.firstWhere((r) => r.id == recipeId);
          _likesCount = recipe.likesCount;
          print(' [LIKE STATUS] Found in searchResults, likesCount: $_likesCount');
        } catch (e2) {
          print(' [LIKE STATUS] Not found in provider lists, will load from API');
        }
      }
    } catch (e) {
      print(' [LIKE STATUS] Error loading from provider: $e');
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleBookmark() async {

    final recipeId = int.tryParse(widget.post.id);
    if (recipeId == null) return;
    setState(() {
      _isBookmarking = true;
    });
    try {
      final recipeProvider = context.read<RecipeProvider>();
      await recipeProvider.toggleBookmarkRecipe(recipeId);
      _isBookmarked = recipeProvider.bookmarkedRecipeIds.contains(recipeId);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'Đã lưu công thức' : 'Đã bỏ lưu công thức'),
            backgroundColor: _isBookmarked ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBookmarking = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {

    final recipeId = int.tryParse(widget.post.id);
    if (recipeId == null) {
      print(' [TOGGLE LIKE] Invalid recipe ID: ${widget.post.id}');
      return;
    }
    print('[TOGGLE LIKE] Toggling like for recipe $recipeId');
    print(' [TOGGLE LIKE] Current state - isLiked: $_isLiked, likesCount: $_likesCount');
    setState(() {
      _isLiking = true;
    });
    try {
      print(' [TOGGLE LIKE] Calling API: toggleLikeRecipe($recipeId)');
      final apiResponse = await RecipeRepository.toggleLikeRecipe(recipeId);
      print(' [TOGGLE LIKE] API Response - success: ${apiResponse.success}, message: ${apiResponse.message}');
      if (apiResponse.success && apiResponse.data != null) {
        final oldLiked = _isLiked;
        final oldLikesCount = _likesCount;
        _isLiked = apiResponse.data!.liked;
        _likesCount = apiResponse.data!.likesCount;
        print(' [TOGGLE LIKE] Updated from API response:');
        print('   isLiked: $oldLiked → $_isLiked');
        print('   likesCount: $oldLikesCount → $_likesCount');
        final recipeProvider = context.read<RecipeProvider>();
        await recipeProvider.loadLikedRecipeIds();
        print(' [TOGGLE LIKE] Provider likedRecipeIds updated');
      } else {
        print(' [TOGGLE LIKE] API response failed, using fallback method');
        final recipeProvider = context.read<RecipeProvider>();
        await recipeProvider.toggleLikeRecipe(recipeId);
        _isLiked = recipeProvider.likedRecipeIds.contains(recipeId);
        print(' [TOGGLE LIKE] Reloading recipe detail to get updated likesCount...');
        final updatedRecipe = await recipeProvider.getRecipeById(recipeId);
        if (updatedRecipe != null) {
          final oldLikesCount = _likesCount;
          _likesCount = updatedRecipe.likesCount;
          print(' [TOGGLE LIKE] Updated likesCount from recipe detail: $oldLikesCount → $_likesCount');
        } else {
          print(' [TOGGLE LIKE] Failed to reload recipe detail');
        }
      }
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? 'Đã thích công thức' : 'Đã bỏ thích công thức'),
            backgroundColor: _isLiked ? Colors.red : Colors.grey,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print(' [TOGGLE LIKE] Error: $e');
      print(' [TOGGLE LIKE] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  Future<void> _addComment() async {

    final recipeId = int.tryParse(widget.post.id);
    if (recipeId == null) return;
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung bình luận'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      return;
    }
    try {
      final commentProvider = context.read<CommentProvider>();
      final response = await commentProvider.addComment(recipeId, commentText);
      if (response.success) {
        _commentController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm bình luận thành công'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Lỗi thêm bình luận'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    }
  }

  Future<void> _addReply(Comment parentComment) async {

    final recipeId = int.tryParse(widget.post.id);
    if (recipeId == null) return;
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung trả lời'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      return;
    }
    try {
      final commentProvider = context.read<CommentProvider>();
      final response = await commentProvider.addComment(
        recipeId,
        replyText,
        parentCommentId: parentComment.id,
        repliedToUserId: parentComment.userId,
        repliedToUserName: parentComment.userName,
      );
      if (response.success) {
        _replyController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm trả lời thành công'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Lỗi thêm trả lời'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    }
  }

  void _showReplyDialog(Comment comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                  backgroundImage: comment.userAvatar != null
                      ? NetworkImage(ApiConfig.fixImageUrl(comment.userAvatar!))
                      : null,
                  child: comment.userAvatar == null
                      ? const Icon(Icons.person, color: Color(0xFF64748B))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trả lời @${comment.userName ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        comment.comment,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _replyController,
              maxLines: 4,
              autofocus: true,
              onTap: () {
                if (_replyController.text.isEmpty) {
                  _replyController.text = '@${comment.userName ?? 'Unknown'} ';
                  _replyController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _replyController.text.length),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: 'Viết trả lời của bạn...',
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF3A16), width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await _addReply(comment);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF3A16),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đăng trả lời',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        );
      },
    );
  }

  void _showCommentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Thêm bình luận',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Viết bình luận của bạn...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEF3A16), width: 2),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await _addComment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF3A16),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đăng bình luận',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        );
      },
    );
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
              title: Text(
                widget.post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: _isLiking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red[300] : Colors.white,
                          ),
                    onPressed: _isLiking ? null : _toggleLike,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: _isBookmarking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                          ),
                    onPressed: _isBookmarking ? null : _toggleBookmark,
                  ),
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF3A16).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFEF3A16).withOpacity(0.6),
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
        child: FloatingActionButton.small(
          backgroundColor: const Color(0xFFEF3A16),
          elevation: 0,
          onPressed: _showCommentDialog,
          child: const Icon(Icons.add_comment, color: Colors.white, size: 20),
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
          ...List.generate(10, (index) =>
            Positioned(
              top: (index * 70.0) % MediaQuery.of(context).size.height,
              left: (index * 90.0) % MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 5000 + (index * 400)),
                curve: Curves.easeInOut,
                width: 4 + (index % 2) * 2,
                height: 4 + (index % 2) * 2,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFEF3A16).withOpacity(0.15)
                      : const Color(0xFFFF6B35).withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                    backgroundImage: _recipeDetail?.userAvatar != null && _recipeDetail!.userAvatar!.isNotEmpty
                        ? NetworkImage(ApiConfig.fixImageUrl(_recipeDetail!.userAvatar!))
                        : null,
                    child: _recipeDetail?.userAvatar == null || _recipeDetail!.userAvatar!.isEmpty
                        ? const Icon(Icons.person, color: Color(0xFF64748B))
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Người đăng: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _navigateToAuthorProfile(),
                            child: Text(
                              widget.post.author,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEF3A16),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFFEF3A16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.post.getFormattedTime(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.post.imageUrl.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFF1F5F9),
                            const Color(0xFFE2E8F0),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.image, size: 64, color: Color(0xFF64748B)),
                    )
                  : Image.network(widget.post.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
            child: Text(
              widget.post.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: 0.3,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (_isLiked ? Colors.red.shade900.withOpacity(0.3) : const Color(0xFF0F0F0F))
                          : (_isLiked ? Colors.red.shade50.withOpacity(0.5) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? (_isLiked ? Colors.red.shade700.withOpacity(0.6) : Colors.white.withOpacity(0.15))
                            : (_isLiked ? Colors.red.shade200.withOpacity(0.6) : const Color(0xFFE2E8F0)),
                        width: isDark ? 2.0 : 1.5,
                      ),
                      boxShadow: isDark ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isDark
                              ? (_isLiked ? Colors.red.shade400 : Colors.grey[400]!)
                              : (_isLiked ? Colors.red.shade600 : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_likesCount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? (_isLiked ? Colors.red.shade300 : Colors.white)
                                : (_isLiked ? Colors.red.shade700 : const Color(0xFF1F2937)),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
                        width: isDark ? 2.0 : 1.5,
                      ),
                      boxShadow: isDark ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 20,
                          color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Consumer<RecipeProvider>(
                          builder: (context, recipeProvider, child) {
                            final recipeId = int.tryParse(widget.post.id);
                            if (recipeId == null) {
                              return Text(
                                '${widget.post.savedCount}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  letterSpacing: 0.3,
                                ),
                              );
                            }

                            final recipe = recipeProvider.recipes.firstWhere(
                              (r) => r.id == recipeId,
                              orElse: () => recipeProvider.searchResults.firstWhere(
                                (r) => r.id == recipeId,
                                orElse: () => Recipe(
                                  id: recipeId,
                                  title: widget.post.title,
                                  imageUrl: widget.post.imageUrl,
                                  servings: 4,
                                  cookingTime: 30,
                                  userId: 0,
                                  userName: widget.post.author,
                                  ingredients: [],
                                  steps: [],
                                  bookmarksCount: widget.post.savedCount,
                                ),
                              ),
                            );
                            return Text(
                              '${recipe.bookmarksCount}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                                letterSpacing: 0.3,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
                  'Nguyên liệu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.post.ingredients.map((ing) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
                      width: isDark ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF3A16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ing,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
                  'Cách nấu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                _isLoadingRecipe
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _recipeDetail != null && _recipeDetail!.steps.isNotEmpty
                        ? Column(
                            children: _recipeDetail!.steps.map((step) => _buildStepCard(step)).toList(),
                          )
                        : Column(
                            children: List.generate(widget.post.steps.length, (i) => _buildSimpleStepCard(i, widget.post.steps[i])),
                          ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildRatingSection(),
          const SizedBox(height: 20),
          Container(
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
                  'Bình luận',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<CommentProvider>(
                  builder: (context, commentProvider, child) {
                    if (commentProvider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final comments = commentProvider.getCommentsForRecipe(int.tryParse(widget.post.id) ?? 0);
                    if (comments.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chưa có bình luận nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: comments.map((comment) => _buildComment(comment)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
          ),
        ],
      ),
    );
  }
  Widget _buildStepCard(RecipeStep step) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
          width: isDark ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEF3A16),
                      const Color(0xFFFF5A00),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF3A16).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (step.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (step.images.length == 1)
              _buildSingleStepImage(step.images.first)
            else if (step.images.length == 2)
              Row(
                children: step.images
                    .map((img) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildStepImageThumbnail(img),
                          ),
                        ))
                    .toList(),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: step.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildStepImageThumbnail(step.images[index]),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
  Widget _buildSingleStepImage(StepImage stepImage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        stepImage.imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 2.0,
              ) : null,
            ),
            child: Center(
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: isDark ? Colors.grey[600] : const Color(0xFF94A3B8),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildStepImageThumbnail(StepImage stepImage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        stepImage.imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 2.0,
              ) : null,
            ),
            child: Center(
              child: Icon(
                Icons.broken_image,
                size: 32,
                color: isDark ? Colors.grey[600] : const Color(0xFF94A3B8),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildSimpleStepCard(int index, String stepText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
          width: isDark ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEF3A16),
                  const Color(0xFFFF5A00),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF3A16).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              stepText,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRatingSection() {
    final recipeId = int.tryParse(widget.post.id) ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
      child: Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          final myRating = ratingProvider.getMyRating(recipeId);
          final stats = ratingProvider.getRatingStats(recipeId);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đánh giá món ăn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              if (stats != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF3A16), Color(0xFFFF5A00)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF3A16).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            stats.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) => const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.white,
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stats.ratingsCount} đánh giá',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dựa trên ${stats.ratingsCount} người dùng',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
              ],
              Text(
                'Đánh giá của bạn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final isSelected = myRating != null && starValue <= myRating.rating;
                  final hasRated = myRating != null;
                  return GestureDetector(
                    onTap: hasRated ? null : () => _rateRecipe(recipeId, starValue),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isSelected ? Icons.star : Icons.star_border,
                        size: 40,
                        color: isSelected
                            ? const Color(0xFFFFA500)
                            : (hasRated
                                ? const Color(0xFFE2E8F0).withOpacity(0.5)
                                : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  );
                }),
              ),
              if (myRating != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF3A16).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFEF3A16),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bạn đã đánh giá ${myRating.rating} sao',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEF3A16),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Nhấn vào sao để đánh giá (chỉ đánh giá 1 lần)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _rateRecipe(int recipeId, int rating) async {
    print('⭐ [RATING] User rating: $rating stars for recipe $recipeId');
    final ratingProvider = context.read<RatingProvider>();
    final response = await ratingProvider.addRating(recipeId, rating);
    if (!mounted) return;
    if (response.success) {
      print(' [RATING] Rating successful, reloading stats...');
      await ratingProvider.loadRatingStats(recipeId);
      _loadRecipeDetail(recipeId);
      context.read<RecipeProvider>().loadRecipes();
      context.read<RecipeProvider>().loadMyRecipes();
      print(' [RATING] Stats reloaded');
      print(' [RATING] New average: ${response.data?.averageRating}');
      print(' [RATING] Total ratings: ${response.data?.ratingsCount}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đánh giá $rating sao!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Đánh giá thất bại'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
  Widget _buildComment(Comment comment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
          width: isDark ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                backgroundImage: comment.userAvatar != null
                    ? NetworkImage(ApiConfig.fixImageUrl(comment.userAvatar!))
                    : null,
                child: comment.userAvatar == null
                    ? Icon(Icons.person, color: isDark ? Colors.grey[400] : const Color(0xFF64748B))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildCommentText(comment),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showReplyDialog(comment),
                icon: const Icon(Icons.reply, size: 16, color: Color(0xFFEF3A16)),
                label: const Text(
                  'Trả lời',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF3A16),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildRepliesSection(comment),
          ],
        ],
      ),
    );
  }
  Widget _buildRepliesSection(Comment comment) {
    final isExpanded = _expandedReplies[comment.id] ?? false;
    final totalReplies = comment.replies.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedReplies[comment.id] = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: const Color(0xFF0284C7),
                ),
                const SizedBox(width: 6),
                Text(
                  isExpanded
                      ? 'Ẩn câu trả lời'
                      : '$totalReplies câu trả lời',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 52),
            child: Column(
              children: comment.replies.map((reply) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: Colors.white.withOpacity(0.15), width: 2.0) : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFE2E8F0),
                      backgroundImage: reply.userAvatar != null
                          ? NetworkImage(ApiConfig.fixImageUrl(reply.userAvatar!))
                          : null,
                      child: reply.userAvatar == null
                          ? Icon(Icons.person, color: isDark ? Colors.grey[400] : const Color(0xFF64748B), size: 18)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.userName ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          _buildCommentText(reply),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
  Widget _buildCommentText(Comment comment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (comment.repliedToUserName != null && comment.repliedToUserName!.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          if (comment.repliedToUserId != null) {
            _navigateToUserProfile(comment.repliedToUserId!);
          }
        },
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '@${comment.repliedToUserName} ',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFEF3A16),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(
                text: comment.comment,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Text(
      comment.comment,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
      ),
    );
  }

  void _navigateToUserProfile(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtherUserProfileScreen(userId: userId),
      ),
    );
  }

  Future<void> _navigateToAuthorProfile() async {

    final recipeId = int.tryParse(widget.post.id);
    if (recipeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải thông tin tác giả'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    int? authorUserId = _recipeDetail?.userId;
    if (authorUserId == null) {
      final recipeProvider = context.read<RecipeProvider>();
      try {
        final recipe = recipeProvider.recipes.firstWhere(
          (r) => r.id == recipeId,
          orElse: () {
            try {
              return recipeProvider.searchResults.firstWhere((r) => r.id == recipeId);
            } catch (e) {
              throw Exception('Not found');
            }
          },
        );
        authorUserId = recipe.userId;
        print(' [AUTHOR PROFILE] Found userId from provider: $authorUserId');
      } catch (e) {
        print(' [AUTHOR PROFILE] Not found in provider, loading recipe detail...');
        try {
          await _loadRecipeDetail(recipeId);
          authorUserId = _recipeDetail?.userId;
          print(' [AUTHOR PROFILE] Loaded userId from API: $authorUserId');
        } catch (e2) {
          print(' [AUTHOR PROFILE] Failed to load recipe detail: $e2');
        }
      }
    }
    if (authorUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải thông tin tác giả'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (!mounted) return;
    if (currentUser != null && currentUser.id == authorUserId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UserProfileScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(userId: authorUserId!),
        ),
      );
    }
  }
}
