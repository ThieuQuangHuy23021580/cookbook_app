import 'package:flutter/material.dart';
import '../../models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
        backgroundColor: const Color(0xFFEF3A16),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xFFEF3A16),
        onPressed: () {},
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(child: Text('Người đăng: ${post.author} • ${post.minutesAgo} phút trước')),
              const Icon(Icons.bookmark, size: 16),
              const SizedBox(width: 4),
              Text('${post.savedCount}'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: post.imageUrl.isEmpty
                ? const Icon(Icons.image, size: 48, color: Colors.white70)
                : Image.asset(post.imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Nguyên liệu', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...post.ingredients.map((ing) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline, size: 18),
                title: Text(ing),
              )),
          const SizedBox(height: 12),
          const Text('Cách nấu', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List.generate(post.steps.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: const Color(0xFFEF3A16), child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(post.steps[i])),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          const Text('Bình luận', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List.generate(3, (i) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Người dùng ${i + 1}'),
                subtitle: const Text('Bình luận ví dụ...'),
              )),
        ],
      ),
    );
  }
}


