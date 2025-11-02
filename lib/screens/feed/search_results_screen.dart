import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/recipe_model.dart';
import '../../providers/recipe_provider.dart';
import 'post_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final List<String>? includeIngredients;
  final List<String>? excludeIngredients;
  const SearchResultsScreen({
    super.key, 
    required this.initialQuery,
    this.includeIngredients,
    this.excludeIngredients,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _pageNewest = 1;
  int _pagePopular = 1;
  List<Recipe> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    print('🔍 [SEARCH RESULTS] Initialized with:');
    print('   initialQuery: "${widget.initialQuery}"');
    print('   includeIngredients: ${widget.includeIngredients}');
    print('   excludeIngredients: ${widget.excludeIngredients}');
    
    // Search for recipes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final recipeProvider = context.read<RecipeProvider>();
    
    // If has ingredient filters, use filter API
    if (widget.includeIngredients != null || widget.excludeIngredients != null) {
      print('🔍 [SEARCH] Using ingredient filter API');
      print('   Include: ${widget.includeIngredients}');
      print('   Exclude: ${widget.excludeIngredients}');
      
      await recipeProvider.filterByIngredients(
        includeIngredients: widget.includeIngredients,
        excludeIngredients: widget.excludeIngredients,
      );
      
      if (!mounted) return;
      
      // Get results from provider
      final allResults = recipeProvider.searchResults;
      print('✅ [SEARCH] Got ${allResults.length} results from filter API');
      
      // If also has title query, filter results by title on client-side
      if (widget.initialQuery.isNotEmpty) {
        final filteredResults = allResults.where((recipe) {
          return recipe.title.toLowerCase().contains(widget.initialQuery.toLowerCase());
        }).toList();
        print('📝 [SEARCH] Filtered by title "${widget.initialQuery}": ${filteredResults.length} results');
        if (mounted) {
          setState(() {
            _filteredResults = filteredResults;
          });
        }
      } else {
        // Only ingredient filter, no title search
        if (mounted) {
          setState(() {
            _filteredResults = allResults;
          });
        }
      }
    } else if (widget.initialQuery.isNotEmpty) {
      // Only title search, no ingredient filter
      print('🔍 [SEARCH] Using title search API: "${widget.initialQuery}"');
      await recipeProvider.searchRecipes(widget.initialQuery);
      if (mounted) {
        // For title-only search, use provider results directly
        // Don't set _filteredResults so it uses recipeProvider.searchResults
        setState(() {
          _filteredResults = [];
        });
      }
    } else {
      // No search query and no filters - show empty
      print('⚠️ [SEARCH] No search query and no filters');
      if (mounted) {
        setState(() {
          _filteredResults = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
      ),
    );
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: isDark
                      ? const Color(0xFFEF3A16).withOpacity(0.15)
                      : const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
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
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Search Query Display
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.initialQuery.isNotEmpty 
                                  ? 'Kết quả cho "${widget.initialQuery}"'
                                  : 'Kết quả tìm kiếm',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.includeIngredients != null || widget.excludeIngredients != null)
                              Text(
                                _buildFilterDescription(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                        width: isDark ? 2.0 : 1.0,
                      ),
                    ),
                    boxShadow: isDark ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFEF3A16),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFFEF3A16),
                    unselectedLabelColor: isDark ? Colors.grey[400] : const Color(0xFF64748B),
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
        // Use filtered results if we have ingredient filters (with or without title query)
        // Otherwise use provider search results (for title-only search)
        final hasIngredientFilters = (widget.includeIngredients != null && widget.includeIngredients!.isNotEmpty) 
            || (widget.excludeIngredients != null && widget.excludeIngredients!.isNotEmpty);
        final resultsToUse = hasIngredientFilters 
            ? _filteredResults 
            : (widget.initialQuery.isNotEmpty 
                ? recipeProvider.searchResults 
                : []);
        
        // Debug log
        print('📊 [BUILD TAB] hasIngredientFilters: $hasIngredientFilters');
        print('   _filteredResults.length: ${_filteredResults.length}');
        print('   recipeProvider.searchResults.length: ${recipeProvider.searchResults.length}');
        print('   resultsToUse.length: ${resultsToUse.length}');
        
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        if (recipeProvider.isSearching) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFFFF6B35) : const Color(0xFFEF3A16),
              ),
            ),
          );
        }
        
        if (recipeProvider.searchError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: isDark ? Colors.grey[400] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra: ${recipeProvider.searchError}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _performSearch();
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
        
        if (resultsToUse.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không tìm thấy kết quả nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy thử từ khóa khác',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        return _pagedList(
          recipes: resultsToUse,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sort recipes based on tab
    final sortedRecipes = List<dynamic>.from(recipes);
    if (isNewest) {
      // Sắp xếp theo thời gian tạo (mới nhất trước)
      sortedRecipes.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(1970);
        final bDate = b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate); // Giảm dần: mới nhất trước
      });
    } else {
      // Sắp xếp theo số lượt thích (phổ biến - nhiều like trước)
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
            color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                width: isDark ? 2.0 : 1.0,
              ),
            ),
            boxShadow: isDark ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ] : null,
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
                    backgroundColor: page > 1 ? const Color(0xFFEF3A16) : (isDark ? Colors.grey[700] : Colors.grey[300]),
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
                  color: isDark ? const Color(0xFF0F0F0F) : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                    width: isDark ? 2.0 : 1.0,
                  ),
                  boxShadow: isDark ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  'Trang $page',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                    backgroundColor: endIndex < sortedRecipes.length ? const Color(0xFFEF3A16) : (isDark ? Colors.grey[700] : Colors.grey[300]),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                              border: isDark ? Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 2.0,
                              ) : null,
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
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${recipe.userName ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
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

  String _buildFilterDescription() {
    final parts = <String>[];
    if (widget.includeIngredients != null && widget.includeIngredients!.isNotEmpty) {
      parts.add('Có: ${widget.includeIngredients!.join(", ")}');
    }
    if (widget.excludeIngredients != null && widget.excludeIngredients!.isNotEmpty) {
      parts.add('Không có: ${widget.excludeIngredients!.join(", ")}');
    }
    return parts.join(' | ');
  }
}


