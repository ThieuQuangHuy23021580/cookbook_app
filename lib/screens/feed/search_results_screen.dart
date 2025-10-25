import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
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
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(106),
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
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    'Kết quả: "${widget.initialQuery}"',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 20,
                    ),
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'Mới nhất'),
                      Tab(text: 'Phổ biến'),
                    ],
                  ),
                ),
              ],
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
          ...List.generate(12, (index) => 
            Positioned(
              top: (index * 60.0) % MediaQuery.of(context).size.height,
              left: (index * 80.0) % MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 4000 + (index * 300)),
                curve: Curves.easeInOut,
                width: 5 + (index % 2) * 3,
                height: 5 + (index % 2) * 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          Consumer<RecipeProvider>(
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
                        recipeProvider.searchError!,
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
                        'Không tìm thấy kết quả cho "${widget.initialQuery}"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  // Filter info
                  if (widget.includeFilter != null && widget.includeFilter!.isNotEmpty || 
                      widget.excludeFilter != null && widget.excludeFilter!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: Color(0xFFEF3A16),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.includeFilter != null && widget.includeFilter!.isNotEmpty)
                                  Text(
                                    'Bao gồm: ${widget.includeFilter}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1F2937),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                if (widget.excludeFilter != null && widget.excludeFilter!.isNotEmpty)
                                  Text(
                                    'Loại trừ: ${widget.excludeFilter}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1F2937),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Clear filters and search again
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF64748B),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _pagedList(
                          recipes: recipeProvider.searchResults,
                          isNewest: true,
                          page: _pageNewest,
                          onPrev: () => setState(() => _pageNewest = (_pageNewest > 1) ? _pageNewest - 1 : 1),
                          onNext: () => setState(() => _pageNewest++),
                        ),
                        _pagedList(
                          recipes: recipeProvider.searchResults,
                          isNewest: false,
                          page: _pagePopular,
                          onPrev: () => setState(() => _pagePopular = (_pagePopular > 1) ? _pagePopular - 1 : 1),
                          onNext: () => setState(() => _pagePopular++),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _pagedList({required List<dynamic> recipes, required bool isNewest, required int page, required VoidCallback onPrev, required VoidCallback onNext}) {
    // Sort recipes based on tab
    final sortedRecipes = List.from(recipes);
    if (isNewest) {
      sortedRecipes.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
    } else {
      sortedRecipes.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    }
    
    final itemsPerPage = 10;
    final totalPages = (sortedRecipes.length / itemsPerPage).ceil();
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, sortedRecipes.length);
    final currentRecipes = sortedRecipes.sublist(startIndex, endIndex);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: currentRecipes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final recipe = currentRecipes[i];
              return _buildRecipeCard(recipe);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Previous button - Neumorphism
              GestureDetector(
                onTap: page > 1 ? onPrev : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: page > 1 ? const Color(0xFFF1F5F9) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: page > 1 ? [
                      BoxShadow(
                        color: const Color(0xFF64748B).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 8,
                        offset: const Offset(-4, -4),
                      ),
                    ] : null,
                  ),
                  child: Text(
                    'Trang trước',
                    style: TextStyle(
                      color: page > 1 ? const Color(0xFF475569) : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Page number - Glassmorphism
              const SizedBox(width: 12),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEF3A16).withOpacity(0.8),
                      const Color(0xFFFF5A00).withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF3A16).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                  child: Text(
                    'Trang $page',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
              ),

              const SizedBox(width: 12),
              // Next button - Neumorphism
              GestureDetector(
                  onTap: onNext,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64748B).withOpacity(0.2),
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
                    child: const Text(
                      'Trang sau',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Post> _generateMockPosts(bool isNewest, int page) {
    final baseIndex = (page - 1) * 10;
    return List.generate(10, (i) {
      final index = baseIndex + i;
      return Post(
        id: 'post_${isNewest ? 'newest' : 'popular'}_$index',
        title: 'Món ${isNewest ? 'Mới' : 'Phổ biến'} ${index + 1}',
        author: 'Người dùng ${(index % 5) + 1}',
        minutesAgo: (index % 60) + 1,
        savedCount: (index % 100) + 10,
        imageUrl: 'https://picsum.photos/300/200?random=$index',
        ingredients: ['Nguyên liệu 1', 'Nguyên liệu 2', 'Nguyên liệu 3'],
        steps: ['Bước 1', 'Bước 2', 'Bước 3'],
      );
    });
  }

  Widget _buildRecipeCard(dynamic recipe) {
    return GestureDetector(
      onTap: () {
        // Convert recipe to Post format for PostDetailScreen
        final post = Post(
          id: recipe.id.toString(),
          title: recipe.title,
          author: recipe.userName,
          minutesAgo: recipe.createdAt != null 
              ? DateTime.now().difference(recipe.createdAt).inMinutes
              : 0,
          savedCount: recipe.bookmarksCount,
          imageUrl: recipe.imageUrl ?? '',
          ingredients: recipe.ingredients.map((ing) => '${ing.name} ${ing.quantity} ${ing.unit}').toList(),
          steps: recipe.steps.map((step) => '${step.stepNumber}. ${step.title}: ${step.description}').toList(),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Recipe image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFF1F5F9),
                  child: recipe.imageUrl != null && recipe.imageUrl.isNotEmpty
                      ? Image.network(
                          recipe.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.restaurant,
                            color: Color(0xFF64748B),
                            size: 32,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: Color(0xFF64748B),
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bởi ${recipe.userName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.cookingTime != null 
                              ? '${recipe.cookingTime} phút'
                              : 'Không xác định',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.likesCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron icon
              SizedBox(
                width: 32,
                height: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64748B).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
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
                      post.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFF1F5F9),
                                const Color(0xFFE2E8F0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.image, color: Color(0xFF64748B), size: 32),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bởi ${post.author}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.minutesAgo} phút trước',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bookmark,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.savedCount}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64748B).withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF64748B),
                        size: 20,
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
  }
}


