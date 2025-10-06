import 'package:flutter/material.dart';
import '../../widgets/search_field.dart';
import '../../models/post.dart';
import 'post_detail_screen.dart';
import 'new_post_screen.dart';
import '../profile/user_profile_screen.dart';
import '../settings_screen.dart';
import 'search_results_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<String> popularKeywords = const ['Gà', 'Bò', 'Cá', 'Chay', 'Mì', 'Bánh'];
  final List<String> recentKeywords = const ['Bún bò', 'Canh chua', 'Sushi', 'Bánh mì', 'Salad'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEF3A16), Color(0xFFFF5A00)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: SearchField(
                    hint: 'Tìm món, nguyên liệu...',
                    onSubmitted: (q) => _openSearch(q),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Từ khóa phổ biến'),
          const SizedBox(height: 8),
          _popularGrid(),
          const SizedBox(height: 20),
          _sectionHeader('Món bạn mới xem gần đây'),
          const SizedBox(height: 8),
          _recentHorizontal(),
          const SizedBox(height: 20),
          _sectionHeader('Tìm kiếm gần đây'),
          const SizedBox(height: 8),
          ...recentKeywords.asMap().entries.map((entry) {
            final index = entry.key;
            final keyword = entry.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(keyword),
              subtitle: Text('${(index + 1) * 2} tiếng trước'),
              trailing: const Icon(Icons.north_east, size: 16),
              onTap: () => _openSearch(keyword),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF3A16),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPostScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _popularGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Placeholder image-box
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFD1C2),
                        const Color(0xFFFFF0E6),
                      ],
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.fastfood, size: 40, color: Colors.black26),
                ),
                // Dark gradient overlay at bottom for readable text
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                      ),
                    ),
                    child: Text(
                      k,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _recentHorizontal() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () {
            final post = Post(
              id: 'r_$i',
              title: 'Món số ${i + 1}',
              author: '@foodlover',
              minutesAgo: 5 + i,
              savedCount: 30 + i,
              imageUrl: '',
              ingredients: const ['Nguyên liệu 1', 'Nguyên liệu 2', 'Nguyên liệu 3'],
              steps: const ['Bước 1 ...', 'Bước 2 ...', 'Bước 3 ...'],
            );
            Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
          },
          child: Container(
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3))],
          ),
        ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 10,
      ),
    );
  }

  void _openSearch(String query) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(initialQuery: query)));
  }
}


