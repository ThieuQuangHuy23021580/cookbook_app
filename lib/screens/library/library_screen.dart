import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/recipe_provider.dart';
import '../feed/post_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _sort = 'Đã xem gần nhất';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
    // Set system UI overlay style to prevent status bar issues
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final total = recipeProvider.bookmarkedRecipes.length;
        return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
              title: const Text(
                'Kho món ngon của tôi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              toolbarHeight: 80,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
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
          ...List.generate(18, (index) => 
            Positioned(
              top: (index * 55.0) % MediaQuery.of(context).size.height,
              left: (index * 75.0) % MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 3500 + (index * 250)),
                curve: Curves.easeInOut,
                width: 6 + (index % 3) * 2,
                height: 6 + (index % 3) * 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFEF3A16).withOpacity(0.1),
                            const Color(0xFFFF5A00).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF3A16).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant_menu, color: Color(0xFFEF3A16), size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Số công thức đã lưu: $total',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Tìm trong kho món ngon của bạn',
                                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF64748B).withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: _sort,
                            underline: const SizedBox(),
                            style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600),
                            items: const [
                              DropdownMenuItem(value: 'Đã xem gần nhất', child: Text('Đã xem gần nhất')),
                              DropdownMenuItem(value: 'Mới lưu', child: Text('Mới lưu')),
                            ],
                            onChanged: (v) => setState(() {
                              _sort = v ?? _sort;
                              _currentPage = 1;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildPagedList(recipeProvider.bookmarkedRecipes),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildPagedList(List<dynamic> recipes) {
    final totalPages = (recipes.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, recipes.length);
    final currentRecipes = recipes.sublist(startIndex, endIndex);

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
        if (totalPages > 1) _buildPaginationControls(totalPages),
      ],
    );
  }

  // Changing page buttons
  Widget _buildPaginationControls(int totalPages) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
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
              onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _currentPage > 1 ? const Color(0xFFF1F5F9) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _currentPage > 1 ? [
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
                    color: _currentPage > 1 ? const Color(0xFF475569) : Colors.grey[400],
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
                'Trang $_currentPage',
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
              onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _currentPage < totalPages ? const Color(0xFFF1F5F9) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _currentPage < totalPages ? [
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
    );
  }

  List<Post> _generateMockSavedPosts() {
    return List.generate(42, (i) {
      return Post(
        id: 'saved_post_$i',
        title: 'Món đã lưu ${i + 1}',
        author: 'Người dùng ${(i % 5) + 1}',
        minutesAgo: (i % 1440) + 1, // 1-1440 phút (1 ngày)
        savedCount: (i % 200) + 20,
        imageUrl: 'https://picsum.photos/300/200?random=${i + 100}',
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
                          Icons.bookmark,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.bookmarksCount}',
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


