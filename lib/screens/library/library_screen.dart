import 'package:flutter/material.dart';
import '../../models/post.dart';
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
  Widget build(BuildContext context) {
    final total = 42;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho lưu trữ'),
        backgroundColor: const Color(0xFFEF3A16),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tổng số công thức: $total', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm trong kho món ngon của bạn',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _sort,
                      items: const [
                        DropdownMenuItem(value: 'Đã xem gần nhất', child: Text('Đã xem gần nhất')),
                        DropdownMenuItem(value: 'Mới lưu', child: Text('Mới lưu')),
                      ],
                      onChanged: (v) => setState(() {
                        _sort = v ?? _sort;
                        _currentPage = 1;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildPagedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPagedList() {
    final posts = _generateMockSavedPosts();
    final totalPages = (posts.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, posts.length);
    final currentPosts = posts.sublist(startIndex, endIndex);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: currentPosts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final post = currentPosts[i];
              return _buildPostCard(post);
            },
          ),
        ),
        if (totalPages > 1) _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
            child: const Text('Trang trước'),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEF3A16).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Trang $_currentPage', style: const TextStyle(color: Color(0xFFEF3A16), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF3A16), foregroundColor: Colors.white),
            child: const Text('Trang sau'),
          ),
        ],
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


