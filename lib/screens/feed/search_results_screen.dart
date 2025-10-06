import 'package:flutter/material.dart';
import '../../models/post.dart';
import 'post_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  const SearchResultsScreen({super.key, required this.initialQuery});

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả: "${widget.initialQuery}"'),
        backgroundColor: const Color(0xFFEF3A16),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Mới nhất'), Tab(text: 'Phổ biến')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _pagedList(
            isNewest: true,
            page: _pageNewest,
            onPrev: () => setState(() => _pageNewest = (_pageNewest > 1) ? _pageNewest - 1 : 1),
            onNext: () => setState(() => _pageNewest++),
          ),
          _pagedList(
            isNewest: false,
            page: _pagePopular,
            onPrev: () => setState(() => _pagePopular = (_pagePopular > 1) ? _pagePopular - 1 : 1),
            onNext: () => setState(() => _pagePopular++),
          ),
        ],
      ),
    );
  }

  Widget _pagedList({required bool isNewest, required int page, required VoidCallback onPrev, required VoidCallback onNext}) {
    final posts = _generateMockPosts(isNewest, page);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final post = posts[i];
              return _buildPostCard(post);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: page > 1 ? onPrev : null,
                child: const Text('Trang trước'),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF3A16).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Trang $page', style: const TextStyle(color: Color(0xFFEF3A16), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF3A16), foregroundColor: Colors.white),
                child: const Text('Trang sau'),
              ),
            ],
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

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bởi ${post.author}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.minutesAgo} phút trước',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.bookmark,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.savedCount} lượt lưu',
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
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


