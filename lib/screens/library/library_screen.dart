import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/index.dart';
import '../../models/post_model.dart';
import '../../providers/recipe_provider.dart';
import '../feed/post_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _searchQuery = '';
  String _sortBy = 'recent'; // 'recent' = Đã xem gần nhất, 'name' = Theo tên

  @override
  void initState() {
    super.initState();
    // Load bookmarked recipes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadBookmarkedRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated Background
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
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar with Glass Effect
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          
                          
                          const Text(
                            'Kho món ngon của tôi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          // Sort Button
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                                width: isDark ? 2.0 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                                if (isDark)
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.05),
                                    spreadRadius: 2,
                                    blurRadius: 12,
                                    offset: const Offset(0, 0),
                                  ),
                                if (isDark)
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.08),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 0),
                                  ),
                              ],
                            ),
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.sort,
                                color: isDark ? Colors.grey[400] : Colors.white,
                                size: 20,
                              ),
                              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isDark ? BorderSide(color: Colors.white.withOpacity(0.15), width: 2.0) : BorderSide.none,
                              ),
                              onSelected: (value) {
                                setState(() {
                                  _sortBy = value;
                                });
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'recent',
                                  child: Text(
                                    'Đã xem gần nhất',
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'name',
                                  child: Text(
                                    'Theo tên',
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                            width: isDark ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                            if (isDark)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.05),
                                spreadRadius: 2,
                                blurRadius: 12,
                                offset: const Offset(0, 0),
                              ),
                            if (isDark)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.08),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 0),
                              ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: TextStyle(color: isDark ? Colors.white : Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Tìm trong kho món ngon của bạn...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark ? Colors.grey[400] : Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Consumer<RecipeProvider>(
                    builder: (context, recipeProvider, child) {
                      if (recipeProvider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.grey[400]! : const Color(0xFFEF3A16),
                            ),
                          ),
                        );
                      }

                      if (recipeProvider.bookmarkedRecipes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 64,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có công thức nào được lưu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hãy lưu những công thức yêu thích',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filter recipes based on search query
                      final filteredRecipes = recipeProvider.bookmarkedRecipes
                          .where((recipe) =>
                              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              (recipe.userName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
                          .toList();

                      // Sort recipes
                      if (_sortBy == 'name') {
                        // Sắp xếp theo tên (alphabetical)
                        filteredRecipes.sort((a, b) {
                          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
                        });
                      } else {
                        // Mặc định: "Đã xem gần nhất" - đảo ngược danh sách để mới nhất lên đầu
                        // API trả về danh sách IDs theo thứ tự, nên danh sách recipes cũng theo thứ tự đó
                        // Đảo ngược để món nào lưu sau (mới nhất) xếp lên đầu
                        final reversedList = filteredRecipes.reversed.toList();
                        filteredRecipes.clear();
                        filteredRecipes.addAll(reversedList);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return _buildRecipeCard(recipe);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(dynamic recipe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        // Convert recipe to Post format for PostDetailScreen
        final post = Post(
          id: recipe.id.toString(),
          title: recipe.title,
          author: recipe.userName ?? 'Unknown',
          minutesAgo: recipe.createdAt != null 
              ? DateTime.now().difference(recipe.createdAt).inMinutes
              : 0,
          savedCount: recipe.bookmarksCount,
          imageUrl: recipe.imageUrl ?? '',
          ingredients: recipe.ingredients.map<String>((ing) => 
            '${ing.name}${ing.quantity != null ? " ${ing.quantity}" : ""}${ing.unit != null ? " ${ing.unit}" : ""}'
          ).toList(),
          steps: recipe.steps.map<String>((step) => 
            '${step.stepNumber}. ${step.title}${step.description != null ? ": ${step.description}" : ""}'
          ).toList(),
          createdAt: recipe.createdAt,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        ).then((_) {
          if (!mounted) return;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            context.read<RecipeProvider>().loadRecentlyViewedRecipes(limit: 9);
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F0F) : null,
          gradient: isDark ? null : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[200]!,
            width: isDark ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Image with 3D effect
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        if (isDark)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        recipe.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F0F0F) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                              border: isDark ? Border.all(color: Colors.white.withOpacity(0.15), width: 2.0) : null,
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: isDark ? Colors.grey[600] : Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${recipe.userName ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Star rating
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < recipe.averageRating.floor()
                                      ? Icons.star
                                      : (starIndex < recipe.averageRating
                                          ? Icons.star_half
                                          : Icons.star_border),
                                  size: 16,
                                  color: const Color(0xFFFFA500),
                                );
                              }),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              recipe.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${recipe.ratingsCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bookmark button
                  Consumer<RecipeProvider>(
                    builder: (context, recipeProvider, child) {
                      final recipeId = recipe.id;
                      final isBookmarked = recipeProvider.bookmarkedRecipeIds.contains(recipeId);
                      
                      return IconButton(
                        onPressed: () async {
                          try {
                            await recipeProvider.toggleBookmarkRecipe(recipeId);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isBookmarked ? 'Đã bỏ lưu công thức' : 'Đã lưu công thức',
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  ),
                                  backgroundColor: isDark ? const Color(0xFF0F0F0F) : (isBookmarked ? Colors.orange : Colors.green),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isDark ? BorderSide(color: Colors.white.withOpacity(0.15), width: 2.0) : BorderSide.none,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lỗi: $e',
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  ),
                                  backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isDark ? BorderSide(color: Colors.white.withOpacity(0.15), width: 2.0) : BorderSide.none,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked 
                              ? const Color(0xFFEF3A16) 
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
