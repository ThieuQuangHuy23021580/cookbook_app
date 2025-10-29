import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/recipe_provider.dart';
import 'post_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final String? includeFilter;
  final String? excludeFilter;
  const SearchResultsScreen({
    super.key, 
    required this.initialQuery,
    this.includeFilter,
    this.excludeFilter,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _pageNewest = 1;
  int _pagePopular = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Search for recipes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().searchRecipes(widget.initialQuery);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to prevent status bar issues
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFE2E8F0),
                  Color(0xFFF1F5F9),
                ],
                stops: [0.0, 0.5, 1.0],
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
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF1E293B),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Search Query Display
                      Expanded(
                        child: Text(
                          'Kết quả cho "${widget.initialQuery}"',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                      Tab(text: 'Mới nhất'),
                      Tab(text: 'Phổ biến'),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(true), // Newest
                      _buildTabContent(false), // Popular
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isNewest) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        if (recipeProvider.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (recipeProvider.searchError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra: ${recipeProvider.searchError}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    recipeProvider.searchRecipes(widget.initialQuery);
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        
        if (recipeProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không tìm thấy kết quả nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy thử từ khóa khác',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        return _pagedList(
          recipes: recipeProvider.searchResults,
          isNewest: isNewest,
          page: isNewest ? _pageNewest : _pagePopular,
          onPrev: () {
            setState(() {
              if (isNewest) {
                _pageNewest = (_pageNewest - 1).clamp(1, double.infinity).toInt();
              } else {
                _pagePopular = (_pagePopular - 1).clamp(1, double.infinity).toInt();
              }
            });
          },
          onNext: () {
            setState(() {
              if (isNewest) {
                _pageNewest++;
              } else {
                _pagePopular++;
              }
            });
          },
        );
      },
    );
  }

  Widget _pagedList({required List<dynamic> recipes, required bool isNewest, required int page, required VoidCallback onPrev, required VoidCallback onNext}) {
    // Sort recipes based on tab
    final sortedRecipes = List<dynamic>.from(recipes);
    if (isNewest) {
      sortedRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      sortedRecipes.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    }
    
    final itemsPerPage = 10;
    // final totalPages = (sortedRecipes.length / itemsPerPage).ceil();
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, sortedRecipes.length);
    final currentRecipes = sortedRecipes.sublist(startIndex, endIndex);
    return Column(
      children: [
        // Recipe List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentRecipes.length,
            itemBuilder: (context, index) {
              final recipe = currentRecipes[index];
              return _buildRecipeCard(recipe);
            },
          ),
        ),
        
        // Pagination Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Page Button
              SizedBox(
                width: 100,
                child: ElevatedButton.icon(
                  onPressed: page > 1 ? onPrev : null,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: const Text('Trước'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: page > 1 ? const Color(0xFFEF3A16) : Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              // Page Number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Trang $page',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              
              // Next Page Button
              SizedBox(
                width: 100,
                child: ElevatedButton.icon(
                  onPressed: endIndex < sortedRecipes.length ? onNext : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: const Text('Sau'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: endIndex < sortedRecipes.length ? const Color(0xFFEF3A16) : Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(dynamic recipe) {
    return GestureDetector(
      onTap: () {
        // Convert recipe to Post format for PostDetailScreen
        final List<String> ingredientsList = [];
        for (var ing in recipe.ingredients) {
          ingredientsList.add(
            '${ing.name}${ing.quantity != null ? " ${ing.quantity}" : ""}${ing.unit != null ? " ${ing.unit}" : ""}'
          );
        }
        
        final List<String> stepsList = [];
        for (var step in recipe.steps) {
          stepsList.add(step.title);
        }
        
        final post = Post(
          id: recipe.id.toString(),
          title: recipe.title,
          author: recipe.userName ?? 'Unknown',
          minutesAgo: recipe.createdAt != null 
              ? DateTime.now().difference(recipe.createdAt).inMinutes
              : 0,
          savedCount: recipe.bookmarksCount,
          imageUrl: recipe.imageUrl ?? '',
          ingredients: ingredientsList,
          steps: stepsList,
          createdAt: recipe.createdAt,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${recipe.userName ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
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
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${recipe.ratingsCount})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
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
                      
                      return FutureBuilder<bool>(
                        future: Future.value(isBookmarked),
                        builder: (context, snapshot) {
                          final isBookmarkedValue = snapshot.data ?? false;
                          
                          return IconButton(
                            onPressed: () async {
                              try {
                                await recipeProvider.toggleBookmarkRecipe(recipeId);
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isBookmarked ? 'Đã bỏ lưu công thức' : 'Đã lưu công thức',
                                      ),
                                      backgroundColor: isBookmarked ? Colors.orange : Colors.green,
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
                              }
                            },
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? const Color(0xFFEF3A16) : Colors.grey[600],
                            ),
                          );
                        },
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
