import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/index.dart';
import '../../models/post.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/filter_bottom_sheet.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<String> popularKeywords = const ['Thực đơn món ngon mỗi ngày', 'Thịt băm', 'Trứng', 'Cá', 'Đùi gà', 'Bánh'];
  final List<String> recentKeywords = const ['Bún bò', 'Canh chua', 'Sushi', 'Bánh mì', 'Salad'];
  
  // ScrollController cho danh sách món gần đây
  final ScrollController _recentScrollController = ScrollController();
  
  // Search state
  String _currentSearchQuery = '';
  String _includeFilter = '';
  String _excludeFilter = '';

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRecipes();
      context.read<RecipeProvider>().loadLikedRecipeIds();
      context.read<RecipeProvider>().loadBookmarkedRecipeIds();
    });
  }

  @override
  void dispose() {
    _recentScrollController.dispose();
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
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  icon: const CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.person, size: 18, color: Color(0xFFEF3A16))),
                  onSelected: (value) {
                    if (value == 'profile') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
                    } else if (value == 'settings') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    } else if (value == 'logout') {
                      // TODO: handle logout
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
          const SizedBox(height: 15),
          Row(children: [
            _sectionHeader('Từ khóa thịnh hành'),
            const SizedBox(width: 50),
            Text(
                "Cập nhật 04:25",
                style: const TextStyle(fontSize: 13),
            ),
          ],),
          const SizedBox(height: 10),
          _popularGrid(),
          const SizedBox(height: 65),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('Món bạn mới xem gần đây'),
              Row(
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
                  const SizedBox(width: 12),
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
              ),
            ],
          ),
          const SizedBox(height: 10),
          _recentHorizontal(),
          const SizedBox(height: 65),
          _sectionHeader('Tìm kiếm gần đây'),
          const SizedBox(height: 10),
          ...recentKeywords.asMap().entries.map((entry) {
            final index = entry.key;
            final keyword = entry.value;
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
                subtitle: Text(
                  '${(index + 1) * 2} tiếng trước',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.north_east, size: 14, color: Color(0xFF64748B)),
                ),
                onTap: () => _openSearch(keyword),
              ),
            );
          }),
          const SizedBox(height: 15),
            ],
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
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _popularGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: popularKeywords.length,
      itemBuilder: (ctx, i) {
        final k = popularKeywords[i];
        return GestureDetector(
          onTap: () {
            _openSearch(k);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Glassmorphism background
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
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Glassmorphism overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  // Animated floating particles
                  ...List.generate(3, (index) => 
                    Positioned(
                      top: (index * 30.0) % 100,
                      left: (index * 40.0) % 100,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 2000 + (index * 500)),
                        curve: Curves.easeInOut,
                        width: 4 + (index * 2),
                        height: 4 + (index * 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Icon with 3D effect
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.restaurant_menu, 
                      size: 40, 
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  // Bottom overlay gradient covering a portion of the tile (not only behind the text)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      heightFactor: 0.35,
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
        );
      },
    );
  }

  Widget _recentHorizontal() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final recipes = recipeProvider.recipes.take(9).toList();
        
        if (recipeProvider.isLoading) {
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
                'Chưa có công thức nào',
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
                  author: recipe.userName,
                  minutesAgo: recipe.createdAt != null 
                      ? DateTime.now().difference(recipe.createdAt!).inMinutes
                      : 0,
                  savedCount: recipe.bookmarksCount,
                  imageUrl: recipe.imageUrl ?? '',
                  ingredients: recipe.ingredients.map((ing) => '${ing.name} ${ing.quantity} ${ing.unit}').toList(),
                  steps: recipe.steps.map((step) => '${step.stepNumber}. ${step.title}: ${step.description}').toList(),
                );
                Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
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
                    child: Image.network(
                      'https://picsum.photos/200/200?random=$i',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                // Phần thông tin (4/10)
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Tên người đăng
                        Text(
                          '@${recipes[i].userName}',
                          style: const TextStyle(
                            fontSize: 10,
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
                            fontSize: 12,
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

  void _openSearch(String query) {
    _currentSearchQuery = query;
    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(initialQuery: query)));
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialQuery: _currentSearchQuery,
        onApplyFilter: (includeQuery, excludeQuery) {
          setState(() {
            _includeFilter = includeQuery;
            _excludeFilter = excludeQuery;
          });
          
          // Combine search query with filters
          String finalQuery = _currentSearchQuery;
          if (includeQuery.isNotEmpty) {
            finalQuery += ' $includeQuery';
          }
          if (excludeQuery.isNotEmpty) {
            finalQuery += ' -$excludeQuery';
          }
          
          // Navigate to search results with filters
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => SearchResultsScreen(
                initialQuery: finalQuery,
                includeFilter: includeQuery,
                excludeFilter: excludeQuery,
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


